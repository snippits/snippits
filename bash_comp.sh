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
    local prev_arg=${COMP_WORDS[COMP_CWORD-1]}
    local cur_arg=${COMP_WORDS[COMP_CWORD]}
    local num_args=$(( $COMP_CWORD + 1 )) # Including the current cursor argument
    local s_words=("" "${COMP_WORDS[@]}")
    if [[ "${s_words[1]}" == "snippit" ]]; then
        s_words=("${s_words[@]:1}")   # Shift one argument
        num_args=$(( $num_args - 1 )) # Shift one argument
    fi
    local options="-h --help -g -gg -o -net -smp -m -snapshot -enable-kvm -drive"
    local images="arch vexpress debian x86_busybox x86_arch"

    case "$prev_arg" in
        "-smp" | "-m")
            ;;
        "-o" | "-drive")
            COMPREPLY=($(compgen -f "$cur_arg"))
            ;;
        *)
            COMPREPLY=( $(compgen -W "$options $images"  -- $cur_arg) )
            ;;
    esac
}

function _complete_image_manager() {
    local prev_arg=${COMP_WORDS[COMP_CWORD-1]}
    local cur_arg=${COMP_WORDS[COMP_CWORD]}
    local num_args=$(( $COMP_CWORD + 1 )) # Including the current cursor argument
    local s_words=("" "${COMP_WORDS[@]}")
    if [[ "${s_words[1]}" == "snippit" ]]; then
        s_words=("${s_words[@]:1}")   # Shift one argument
        num_args=$(( $num_args - 1 )) # Shift one argument
    fi
    local operation=${s_words[2]}
    local options="-h --help list push pull ls rm mkdir"

    if [[ $snippit_update_flag == 0 ]]; then
        snippit_update_flag=1
        snippit_image_list=$(_get_image_list)
    fi
    case "$operation" in
        "push")
            [[ $num_args == 3 ]] && COMPREPLY=($(compgen -f "$cur_arg"))
            [[ $num_args == 4 ]] && COMPREPLY=( $(compgen -W "${snippit_image_list}" -- $cur_arg) )
            ;;
        "pull")
            [[ $num_args == 3 ]] && COMPREPLY=( $(compgen -W "${snippit_image_list}" -- $cur_arg) )
            [[ $num_args == 4 ]] && COMPREPLY=($(compgen -f "$cur_arg"))
            ;;
        "ls" | "rm" | "mkdir")
            [[ $num_args == 3 ]] && COMPREPLY=( $(compgen -W "${snippit_image_list}" -- $cur_arg) )
            ;;
        *)
            [[ $num_args == 2 ]] && COMPREPLY=( $(compgen -W "$options" -- $cur_arg) )
            ;;
    esac
}

function _complete_snippit() {
    local cur_arg=${COMP_WORDS[COMP_CWORD]}
    local options="qemu image"

    case "${COMP_WORDS[1]}" in
        "qemu")
            _complete_runQEMU
            ;;
        "image")
            _complete_image_manager
            ;;
        *)
            COMPREPLY=( $(compgen -W "${options}" -- ${cur_arg}) )
            ;;
    esac
}

complete -F _complete_snippit snippit
complete -F _complete_runQEMU runQEMU.sh
complete -F _complete_image_manager image_manager.sh

