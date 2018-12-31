#!/usr/bin/zsh
# Copyright (c) 2017, Medicine Yeh

snippit_image_list=""
snippit_update_flag=0

SCRIPT_DIR="$(readlink -f "$(dirname "$0")")"
source "${SCRIPT_DIR}/comp_helper.sh"

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
    local options=('-h:Display help message and information of usage.'
        '--help:Display help message and information of usage.'
        '-g:Use gdb to run QEMU for debugging'
        '-gg:Run QEMU with remote gdb mode to debug guest program'
        '-o:Specify the output directory for emulation'
        '-smp:Number of cores (default: 1)'
        '-m:Size of memory (MB) (default: 1024)'
        '-snapshot:Run with read only guest image'
        '-enable-kvm:Enable KVM'
        '-drive:Hook another disk image to guest'
        '-vpmu-console:Specify the output file for VPMU console output (default stderr)'
        '-mem-path:Use file to allocate guest memory (ex: -mem-path /dev/hugepages)'
        '-trace:Use QEMU trace API with specified events'
        )
    if [[ $snippit_update_flag == 0 ]]; then
        # snippit_update_flag=1
        # Get only the name of directories and filter out directory with name '.' with grep
        snippit_image_list=$(_get_image_list | xargs dirname | grep -v -e '^\.$')
    fi

    case "$prev_arg" in
        "-o")
            _alternative 'files:filenames:_directories'
            ;;
        "-drive" | "-vpmu-console" | "-mem-path")
            _alternative 'files:filenames:_files'
            ;;
        "-m" | "-smp")
            # Do no completion here
            ;;
        *)
            if [[ $curr_arg_num == 2 ]]; then
                _sep_parts "($snippit_image_list)"
            else
                _describe -V 'values' options
            fi
            ;;
    esac
}

function _complete_image_and_path() {
    local cur_arg=$words[${#words[@]}]

    if [[ $snippit_update_flag == 0 ]]; then
        # snippit_update_flag=1
        snippit_image_list=$(_get_image_list)
    fi

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
    local options=('-h:Display help message and information of usage.'
        '--help:Display help message and information of usage.'
        )
    local actions=('list:List all existing images'
        'push:Push a file/folder into image'
        'pull:Pull a file/folder from image'
        'ls:List files in image folder'
        'rm:Remove file/folder from image'
        'mkdir:Make a folder in image'
        'file:Check file info'
        'vim:Edit the file with vim'
        'nano:Edit the file with nano'
        'cat:Print out the content of the file'
        )

    case "$operation" in
        "push")
            [[ $curr_arg_num == 3 ]] &&  _alternative 'files:filenames:_files'
            [[ $curr_arg_num == 4 ]] &&  _complete_image_and_path
            ;;
        "pull")
            [[ $curr_arg_num == 3 ]] &&  _complete_image_and_path
            [[ $curr_arg_num == 4 ]] &&  _alternative 'files:filenames:_files'
            ;;
        "ls" | "rm" | "mkdir" | "file" | "vim" | "nano" | "cat")
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
        'tmux:Startup a tmux UI with preset panes/windows' \
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
        "tmux")
            ;;
        *)
            _describe -V 'values' options
            ;;
    esac
}

compdef _complete_snippit snippit
compdef _complete_runQEMU runQEMU.sh
compdef _complete_image_manager image_manager.py
autoload colors && colors

