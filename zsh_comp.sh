#!/usr/bin/zsh

snippit_image_list=""
snippit_update_flag=0
function _get_image_list() {
    local res=$($RUN_QEMU_SCRIPT_PATH/image_manager.sh list | sed 1,1d | awk '{print $1}')
    res=($res) # Convert to array
    for f in "${res[@]}"; do
        echo $f
    done
}

function _complete_runQEMU() {
    local prev_arg=$words[${#words[@]}-1]
    local cur_arg=$words[${#words[@]}]
    local num_args=${#words[@]} # Including the current cursor argument
    local s_words=(${words})
    if [[ "${s_words[1]}" == "snippit" ]]; then
        s_words=(${s_words:1})        # Shift one argument
        num_args=$(( $num_args - 1 )) # Shift one argument
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
        local image_rootfs="$RUN_QEMU_SCRIPT_PATH/images/rootfs"
        local e2fs_mount_point=$(mount | grep "$image_name" | cut -d " " -f 3)

        if [[ "$e2fs_mount_point" != "" ]]; then
            image_rootfs="$e2fs_mount_point"
        fi
        if [[ $(ls "$image_rootfs" | wc -l) == 0 ]]; then
            _message -r "Image is not mounted(e2fs) or extracted(cpio). No path completion can be done..."
            _message -r "See more in https://github.com/snippits/snippits/blob/master/README.md#completion"
        fi

        if compset -P '*@/'; then
            _files -W "$image_rootfs"
        fi
    fi
}

function _complete_image_manager() {
    local prev_arg=$words[${#words[@]}-1]
    local cur_arg=$words[${#words[@]}]
    local num_args=${#words[@]} # Including the current cursor argument
    local s_words=(${words})
    if [[ "${s_words[1]}" == "snippit" ]]; then
        s_words=(${s_words:1})        # Shift one argument
        num_args=$(( $num_args - 1 )) # Shift one argument
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
            [[ $num_args == 3 ]] &&  _alternative 'files:filenames:_files'
            [[ $num_args == 4 ]] &&  _complete_image_and_path
            ;;
        "pull")
            [[ $num_args == 3 ]] &&  _complete_image_and_path
            [[ $num_args == 4 ]] &&  _alternative 'files:filenames:_files'
            ;;
        "ls" | "rm" | "mkdir")
            [[ $num_args == 3 ]] &&  _complete_image_and_path
            ;;
        *)
            # We are now in second argument
            if [[ $num_args == 2 ]]; then
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

