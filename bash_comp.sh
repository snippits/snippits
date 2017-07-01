#!/usr/bin/bash

snippit_image_list=""
snippit_update_flag=0
function _get_image_list() {
    local res=$($RUN_QEMU_SCRIPT_PATH/image_manager.sh list | sed 1,1d | awk '{print $1}')
    res=($res) # Convert to array
    for f in "${res[@]}"; do
        echo "${f}@/"
    done
}

function _complete_runQEMU() {
    local -a cur prev opts imgs
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="-h --help -g -gg -o -net -smp -m -snapshot -enable-kvm -drive"
    imgs="arch vexpress debian x86_busybox x86_arch"

    case "${prev}" in
        "-smp" | "-m")
            ;;
        "-o" | "-drive")
            COMPREPLY=($(compgen -f "${cur}"))
            ;;
        *)
            COMPREPLY=( $(compgen -W "${opts} ${imgs}"  -- ${cur}) )
            ;;
    esac
}

function _complete_image_manager() {
    local -a cur prev opts operation
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    operation="${COMP_WORDS[2]}"
    opts="-h --help list push pull ls rm mkdir"

    [[ $snippit_update_flag == 0 ]] && snippit_update_flag=1 && snippit_image_list=$(_get_image_list)
    case "${operation}" in
        "push")
            [[ $COMP_CWORD == 3 ]] && COMPREPLY=($(compgen -f "${cur}"))
            [[ $COMP_CWORD == 4 ]] && COMPREPLY=( $(compgen -W "${snippit_image_list}" -- ${cur}) )
            ;;
        "pull")
            [[ $COMP_CWORD == 3 ]] && COMPREPLY=( $(compgen -W "${snippit_image_list}" -- ${cur}) )
            [[ $COMP_CWORD == 4 ]] && COMPREPLY=($(compgen -f "${cur}"))
            ;;
        "ls" | "rm" | "mkdir")
            [[ $COMP_CWORD == 3 ]] && COMPREPLY=( $(compgen -W "${snippit_image_list}" -- ${cur}) )
            ;;
        *)
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            ;;
    esac
}

function _complete_snippit() {
    local -a cur prev opts imgs
    cur="${COMP_WORDS[COMP_CWORD]}"
    opts="qemu image"

    case ${COMP_WORDS[1]} in
        qemu)
            _complete_runQEMU
            ;;
        image)
            _complete_image_manager
            ;;
        *)
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            ;;
    esac
}

complete -F _complete_snippit snippit
complete -F _complete_runQEMU runQEMU.sh
complete -F _complete_image_manager image_manager.sh

