snippit_cpio_rootfs_dir="$(readlink -f "${SNIPPIT_HOME}/.rootfs_cpio")"
snippit_e2fs_rootfs_dir="$(readlink -f "${SNIPPIT_HOME}/.rootfs_e2fs")"
snippit_mbr_rootfs_dir="$(readlink -f "${SNIPPIT_HOME}/.rootfs_mbr")"
snippit_loops_rootfs_dir="$(readlink -f "${SNIPPIT_HOME}/.rootfs_loops")"
snippit_comp_rootfs=""

function image_manager() {
    "$SNIPPIT_HOME/qemu_image/image_manager.py" "$@"
}

function _get_image_list() {
    image_manager query list
}

# Timeout in 5s. This value cannot be too long in order to ensure the mounted dir is latest completion.
# If we wait too long, when a user change the image and the directory would be wrong image's.
function timed_user_remove_cpio() {
    sleep $1
    # Never remove cpio folder when it is somehow mounted by others
    mountpoint -q "$1" && return 4;
    [[ -d "$1" ]] && rm -rf "$2" 2> /dev/null
    mkdir -p "$2"
}

function safe_user_umount() {
    mountpoint -q "$1" && fusermount -quz "$1" 2> /dev/null
}

function timed_user_unmount_e2fs() {
    sleep $1
    safe_user_umount "$2"
}

function timed_user_unmount_mbr() {
    sleep $1
    local partition_folders=($(ls "$snippit_mbr_rootfs_dir"))
    for p in "${partition_folders[@]}"; do
        safe_user_umount "${snippit_mbr_rootfs_dir}/${p}"
        if ! mountpoint -q "${snippit_mbr_rootfs_dir}/${p}"; then
            rmdir "${snippit_mbr_rootfs_dir}/${p}" 2> /dev/null
        fi
    done
    # Unmount loop devices (MBR)
    safe_user_umount "$snippit_loops_rootfs_dir"
}

function user_extract_cpio() {
    local file_path="$(readlink -f "$1")"
    [[ ! -r "$file_path" ]] && exit 4
    rm -rf "$snippit_cpio_rootfs_dir"
    mkdir -p "$snippit_cpio_rootfs_dir"
    (
        # Run as detached process so that no working directory change to the user
        cd "$snippit_cpio_rootfs_dir"
        # Do the dangerous operation only when the current directory is correct for safety
        if [[ "$(pwd)" == "$snippit_cpio_rootfs_dir" ]]; then
            cpio -idu --quiet < "$file_path" 2> /dev/null
        fi
    )
}

# NOTE: return 0 when command not found and return 1 when found
function _check_command() {
    command_found=$(command -v "$1" 2> /dev/null)
    if [[ "$command_found" == "" ]]; then
        return 0 # NOT found
    else
        return 1 # Found
    fi
}

function get_mbr_partitions() {
    local IFS=$'\n' # Change IFS to '\n' locally
    local image_path="$1"
    local partitions=($(image_manager query partitionTableof "$image_path"))

    for p in "${partitions[@]}"; do
        # Skip un-mountable partitions
        [[ "$p" == *"False" ]] && continue
        local index=$(echo "$p" | awk '{print $1}')
        echo $index
    done
}

function user_mount_image() {
    local image_path="$(image_manager query pathof "$1")"
    local image_type="$(image_manager query typeof "$1")"

    # Reset the return path to target rootfs for completion
    snippit_comp_rootfs=""

    case "$image_type" in
    "CPIO")
        snippit_comp_rootfs="$snippit_cpio_rootfs_dir"
        # Issue the cleaner before the mount event to in case user aborts completion
        (timed_user_remove_cpio 5s "$snippit_cpio_rootfs_dir" &)
        user_extract_cpio "$image_path"
        ;;
    "EXT2" | "EXT3" | "EXT4" | "E2FS")
        snippit_comp_rootfs="$snippit_e2fs_rootfs_dir"
        mkdir -p "$snippit_e2fs_rootfs_dir"
        if _check_command ext4fuse || _check_command fusermount; then
            _check_command ext4fuse && _message -r "ext4fuse command not found. No completion can be done."
            _check_command fusermount && _message -r "fusermount command not found. No completion can be done."
            return 4;
        fi
        # Only mount when both command are available
        # Previous mount point will be unmount automatically. Do not unmount here.
        mountpoint -q "$snippit_e2fs_rootfs_dir" && return 4;
        # Issue the cleaner before the mount event to in case user aborts completion
        (timed_user_unmount_e2fs 5s "$snippit_e2fs_rootfs_dir" &)

        ext4fuse "$image_path" "$snippit_e2fs_rootfs_dir" 2> /dev/null
        err_code=$?
        [[ $err_code != 0 ]] && _message -r "Error code $err_code presents when using ext4fuse"
        ;;
    "MBR")
        snippit_comp_rootfs="$snippit_mbr_rootfs_dir"
        mkdir -p "$snippit_mbr_rootfs_dir" "$snippit_loops_rootfs_dir"
        if _check_command ext4fuse || _check_command fusermount || _check_command mbrfs; then
            _check_command mbrfs && _message -r "mbrfs command not found. No completion can be done."
            _check_command ext4fuse && _message -r "ext4fuse command not found. No completion can be done."
            _check_command fusermount && _message -r "fusermount command not found. No completion can be done."
            return 4;
        fi
        # Previous mount point will be unmount automatically. Do not unmount here.
        mountpoint -q "$snippit_loops_rootfs_dir" && return 0
        # Issue the cleaner before the mount event to in case user aborts completion
        (timed_user_unmount_mbr 5s &)

        # Magic here. DO NOT use any read operation (ls/file/etc.) on the mounted mbr folders.
        # That will cause unexpected behaviors to the next ext4fuse mount.
        # Ex: IO errors when completing file paths. Process hangs.
        local partitions=($(get_mbr_partitions "$image_path"))
        # Mount loop devices
        mbrfs "$image_path" "$snippit_loops_rootfs_dir" 2> /dev/null
        local IFS='\n'
        # Mount partitions
        for p in "${partitions[@]}"; do
            local loop_dev="${snippit_loops_rootfs_dir}/${p}"
            local target_dir="${snippit_mbr_rootfs_dir}/p${p}"
            [[ ! -d "$target_dir" ]] && mkdir -p "$target_dir"
            # TODO fuse mount FAT file system
            if [[ "$(file "$loop_dev" | grep "FAT")" == "" ]]; then
                ! mountpoint -q "$target_dir" && ext4fuse "$loop_dev" "$target_dir" 2> /dev/null
            fi
        done
        ;;
    esac
}

