#!/usr/bin/zsh
# Copyright (c) 2017, Medicine Yeh

snippit_image_list=""
snippit_update_flag=0

snippit_cpio_rootfs_dir="$(readlink -f "${SNIPPIT_HOME}/.rootfs_cpio")"
snippit_e2fs_rootfs_dir="$(readlink -f "${SNIPPIT_HOME}/.rootfs_e2fs")"
snippit_mbr_rootfs_dir="$(readlink -f "${SNIPPIT_HOME}/.rootfs_mbr")"
snippit_comp_rootfs=""

function _get_image_list() {
    local res=$($RUN_QEMU_SCRIPT_PATH/image_manager.sh list | sed 1,1d | awk '{print $1}')
    res=($res) # Convert to array
    for f in "${res[@]}"; do
        echo $f
    done
}

# Timeout in 5s. This value cannot be too long in order to ensure the mounted dir is latest completion.
# If we wait too long, when a user change the image and the directory would be wrong image's.
function timed_user_remove_cpio() {
    sleep 5s
    mountpoint -q "$1" && return 4;
    [[ -d "$1" ]] && rm -rf "$1" 2> /dev/null
    mkdir -p "$1"
}

function safe_user_umount() {
    mountpoint -q "$1" && fusermount -quz "$1" 2> /dev/null
}

function timed_user_unmount_e2fs() {
    sleep 5s
    safe_user_umount "$1"
}

function timed_root_unmount_mbr() {
    sleep 3s
    local partition_folders=("$(ls "$1")")
    for p in "${partition_folders[@]}"; do
        [[ -d "$1/$p" ]] && mountpoint -q "$1/$p" && sudo umount "$1/$p"
    done
}

function mount_mbr() {
    local image_path="$1"
    local readonly_flag="$2"
    local sector_size=$(fdisk -l "$image_path" | grep "Sector size" | sed -e "s/.*://g" | sed -e "s/bytes.*//g")
    local partitions=("$(fdisk -l "$image_path" | grep "Linux" | grep -v "swap")")
    local p_name=(p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11 p12 p13 p14 p15 p16)

    local index=0
    for p in "${partitions[@]}"; do
        index=$(( $index + 1 ))
        # Use awk instead of cut to handle multiple spaces
        local sector_start=$(echo "$p" | awk '{print $3}')
        local offset=$(( ${sector_start} * $sector_size ))
        local flags="ro,loop,offset=$offset"

        mkdir -p "$snippit_mbr_rootfs_dir/${p_name[$index]}"
        if mountpoint -q "$snippit_mbr_rootfs_dir/${p_name[$index]}"; then
            # Do nothing when it is already mounted
        else
            sudo mount -o "$flags" "$image_path" "$snippit_mbr_rootfs_dir/${p_name[$index]}"
        fi
    done
}

function user_extract_cpio() {
    local file_path="$(readlink -f "$1")"
    [[ ! -r "$file_path" ]] && exit 4
    mkdir -p "$snippit_cpio_rootfs_dir"
    (
        # Run as detached process so that no working directory change to the user
        cd "$snippit_cpio_rootfs_dir"
        # Do the dangerous operation only when the current directory is correct for safety
        if [[ "$(pwd)" == "$snippit_cpio_rootfs_dir" ]]; then
            cpio -idu --quiet < "$file_path" 2> /dev/null
            (timed_user_remove_cpio "$snippit_cpio_rootfs_dir" &)
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

function user_mount_image() {
    local tmp=($($RUN_QEMU_SCRIPT_PATH/image_manager.sh query image_path_and_type "$1"))
    local image_path="${tmp[1]}"
    local image_type="${tmp[2]}"
    local duration=$3

    # Reset the return path to target rootfs for completion
    snippit_comp_rootfs=""

    case "$image_type" in
    "CPIO")
        snippit_comp_rootfs="$snippit_cpio_rootfs_dir"
        user_extract_cpio "$image_path"
        ;;
    "EXT2" | "EXT3" | "EXT4")
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

        ext4fuse "$image_path" "$snippit_e2fs_rootfs_dir" 2> /dev/null
        err_code=$?
        [[ $err_code != 0 ]] && _message -r "Error code $err_code presents when using ext4fuse"
        (timed_user_unmount_e2fs 5s "$snippit_e2fs_rootfs_dir" &)
        ;;
    "MBR")
        # TODO Try make it userlevel
        snippit_comp_rootfs="$snippit_mbr_rootfs_dir"
        mkdir -p "$snippit_mbr_rootfs_dir"
        mount_mbr "$image_path"
        (timed_root_unmount_mbr "$snippit_mbr_rootfs_dir" &)
        ;;
    esac
}

function _complete_runQEMU() {
    local prev_arg=$words[${CURRENT}-1]
    local cur_arg=$words[${CURRENT}]
    local num_args=${#words[@]} # Including the current cursor argument
    local curr_arg_num=$CURRENT
    local s_words=(${words})
    if [[ "${s_words[1]}" == "snippit" ]]; then
        s_words=(${s_words:1})        # Shift one argument
        num_args=$(( $num_args - 1 )) # Shift one argument
        curr_arg_num=$(( $curr_arg_num - 1 ))
    fi
    local options=('-h:Display help message and information of usage.' \
        '--help:Display help message and information of usage.' \
        '-g:Use gdb to run QEMU for debugging' \
        '-gg:Run QEMU with remote gdb mode to debug guest program' \
        '-o:Specify the output directory for emulation' \
        '-smp:Number of cores (default: 1)' \
        '-m:Size of memory (MB) (default: 1024)' \
        '-snapshot:Run with read only guest image' \
        '-enable-kvm:Enable KVM' \
        '-drive:Hook another disk image to guest' \
        )
    local images=('vexpress:Run Vexpress Image (ARM)' \
        'arch:Run Arch Linux Image (ARM)' \
        'debian:Run Debian Linux Image (ARM)' \
        'x86_busybox:Run x86 image (x86)' \
        'x86_arch:Run arch image (x86)' \
        )

    case "$prev_arg" in
        "-o")
            _alternative 'files:filenames:_directories'
            ;;
        "-drive")
            _alternative 'files:filenames:_files'
            ;;
        "-m" | "-smp")
            # Do no completion here
            ;;
        *)
            _describe -V 'values' options
            _describe -V 'values' images
            ;;
    esac
}

function _complete_image_and_path() {
    local cur_arg=$words[${#words[@]}]

    if [[ "$cur_arg" != *"@"* ]]; then
        # Complete image when typing before @
        _sep_parts "($snippit_image_list)" @/
    else
        # Complete path when typing after @
        local image_name=${cur_arg%%@*}
        local target_dir=${cur_arg##*@}

        user_mount_image "$image_name"

        if [[ -d "$snippit_comp_rootfs" ]] && compset -P '*@/'; then
            _files -W "$snippit_comp_rootfs"
        fi
    fi
}

function _complete_image_manager() {
    local prev_arg=$words[${CURRENT}-1]
    local cur_arg=$words[${CURRENT}]
    local num_args=${#words[@]} # Including the current cursor argument
    local curr_arg_num=$CURRENT
    local s_words=(${words})
    if [[ "${s_words[1]}" == "snippit" ]]; then
        s_words=(${s_words:1})        # Shift one argument
        num_args=$(( $num_args - 1 )) # Shift one argument
        curr_arg_num=$(( $curr_arg_num - 1 ))
    fi
    local operation=${s_words[2]}
    local options=('-h:Display help message and information of usage.' \
        '--help:Display help message and information of usage.' \
        )
    local actions=('list:List all existing images' \
        'push:Push a file/folder into image' \
        'pull:Pull a file/folder from image' \
        'ls:List files in image folder' \
        'rm:Remove file/folder from image' \
        'mkdir:Make a folder in image' \
        )

    if [[ $snippit_update_flag == 0 ]]; then
        snippit_update_flag=1
        snippit_image_list=$(_get_image_list)
    fi
    case "$operation" in
        "push")
            [[ $curr_arg_num == 3 ]] &&  _alternative 'files:filenames:_files'
            [[ $curr_arg_num == 4 ]] &&  _complete_image_and_path
            ;;
        "pull")
            [[ $curr_arg_num == 3 ]] &&  _complete_image_and_path
            [[ $curr_arg_num == 4 ]] &&  _alternative 'files:filenames:_files'
            ;;
        "ls" | "rm" | "mkdir")
            [[ $curr_arg_num == 3 ]] &&  _complete_image_and_path
            ;;
        *)
            # We are now in second argument
            if [[ $curr_arg_num == 2 ]]; then
                _describe -V 'values' options
                _describe -V 'values' actions
            fi
            ;;
    esac
}

function _complete_snippit() {
    local options=('qemu:Run QEMU emulation' \
        'image:Manipulate guest images' \
        )

    case "${words[2]}" in
        "qemu")
            _complete_runQEMU
            ;;
        "image")
            _complete_image_manager
            ;;
        "phase")
            ;;
        *)
            _describe -V 'values' options
            ;;
    esac
}

compdef _complete_snippit snippit
compdef _complete_runQEMU runQEMU.sh
compdef _complete_image_manager image_manager.sh
autoload colors && colors

