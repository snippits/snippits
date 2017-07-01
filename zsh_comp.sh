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
    local -a options images last_arg
    options=('-h:Display help message and information of usage.' \
        '-g:Use gdb to run QEMU for debugging' \
        '-gg:Run QEMU with remote gdb mode to debug guest program' \
        '-o:Specify the output directory for emulation' \
        '-smp:Number of cores (default: 1)' \
        '-m:Size of memory (MB) (default: 1024)' \
        '-snapshot:Run with read only guest image' \
        '-enable-kvm:Enable KVM' \
        '-drive:Hook another disk image to guest' \
        )
    images=('vexpress:Run Vexpress Image (ARM)' \
        'arch:Run Arch Linux Image (ARM)' \
        'debian:Run Debian Linux Image (ARM)' \
        'x86_busybox:Run x86 image (x86)' \
        'x86_arch:Run arch image (x86)' \
        )

    last_arg=$words[${#words[@]}-1]
    case "$last_arg" in
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

function _complete_image_manager() {
    local -a options actions operation num_args images file_list
    options=('-h:Display help message and information of usage.' \
        )
    actions=('list:List all existing images' \
        'push:Push a file/folder into image' \
        'pull:Pull a file/folder from image' \
        'ls:List files in image folder' \
        'rm:Remove file/folder from image' \
        'mkdir:Make a folder in image' \
        )

    operation="${words[3]}"
    num_args=${#words[@]}
    [[ $snippit_update_flag == 0 ]] && snippit_update_flag=1 && snippit_image_list=$(_get_image_list)
    case "$operation" in
        "push")
            [[ $num_args == 4 ]] &&  _alternative 'files:filenames:_files'
            [[ $num_args == 5 ]] &&  _sep_parts "($snippit_image_list)" @/
            ;;
        "pull")
            [[ $num_args == 4 ]] &&  _sep_parts "($snippit_image_list)" @/
            [[ $num_args == 5 ]] &&  _alternative 'files:filenames:_files'
            ;;
        "ls" | "rm" | "mkdir")
            [[ $num_args == 4 ]] &&  _sep_parts "($snippit_image_list)" @/
            ;;
        *)
            _describe -V 'values' options
            _describe -V 'values' actions
            ;;
    esac
}

function _complete_snippit() {
    _arguments '1: :->task'

    case $state in
        task)
            _arguments '1:task:(qemu image)'
            ;;
        *)
            case $words[2] in
                qemu)
                    _complete_runQEMU
                    ;;
                image)
                    _complete_image_manager
                    ;;
                phase)
                    ;;
            esac
        ;;
esac
}

compdef _complete_snippit snippit
compdef _complete_runQEMU runQEMU.sh
compdef _complete_image_manager image_manager.sh
autoload colors && colors

