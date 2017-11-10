#!/usr/bin/bash
# Copyright (c) 2017, Medicine Yeh

snippit_image_list=""
snippit_update_flag=0

source "$SNIPPIT_HOME/comp_helper.sh"

function _complete_runQEMU() {
    local prev_arg=${COMP_WORDS[COMP_CWORD-1]}
    local cur_arg=${COMP_WORDS[COMP_CWORD]}
    local num_args=${#COMP_WORDS[@]}          # Including the current cursor argument
    local curr_arg_num=$(( $COMP_CWORD + 1 )) # Including the current cursor argument
    local s_words=("" "${COMP_WORDS[@]}")
    if [[ "${s_words[1]}" == "snippit" ]]; then
        s_words=("${s_words[@]:1}")   # Shift one argument
        num_args=$(( $num_args - 1 )) # Shift one argument
        curr_arg_num=$(( $curr_arg_num - 1 ))
    fi
    local options="-h --help -g -gg -o -net -smp -m -snapshot -enable-kvm -drive -vpmu-console -mem-path -trace"
    if [[ $snippit_update_flag == 0 ]]; then
        # snippit_update_flag=1
        # Get only the name of directories and filter out directory with name '.' with grep
        snippit_image_list=$(_get_image_list | xargs dirname | grep -v -e '^\.$')
    fi

    case "$prev_arg" in
        "-smp" | "-m")
            ;;
        "-o" | "-drive" | "-vpmu-console" | "-mem-path")
            COMPREPLY=($(compgen -f "$cur_arg"))
            ;;
        *)
            if [[ $curr_arg_num == 2 ]]; then
                COMPREPLY=( $(compgen -W "${snippit_image_list}" -- $cur_arg) )
            else
                COMPREPLY=( $(compgen -W "$options $images"  -- $cur_arg) )
            fi
            ;;
    esac
}

function _complete_image_file_path() {
    local image_name="$1"
    local cur="$2"
    local opts=""
    local realcur="${cur##*/}"
    local prefix="${cur%$realcur}"

    # Extract the directory path out of incomplete path
    local dir_path="$snippit_comp_rootfs/$cur"
    [[ ! -d "$dir_path" ]] && dir_path="$(dirname "$dir_path")"
    local file_lists=( $(ls "$dir_path") )

    for w in "${file_lists[@]}"; do
        if ! [[ $prefix == *"$w"* ]]; then
            opts="$w $opts"
        fi
    done

    COMPREPLY=( $(compgen -W "$opts" -S '/' -- $cur) )
    COMPREPLY=( $(compgen -P "$image_name@/$prefix" -W "$opts" -S '/' -- $realcur) )
}

function _complete_image_manager_path() {
    local cur prev image_list
    _get_comp_words_by_ref cur prev

    image_list="$snippit_image_list";

    if [[ "$cur" == *@/* ]]; then
        # Complete path when typing after @
        local image_name=${cur%%@/*}
        local target_dir=${cur##*@/}

        user_mount_image "$image_name"
        if [[ -d "$snippit_comp_rootfs" ]]; then
            _complete_image_file_path "$image_name" "$target_dir"
        fi
    else
        # Complete image when typing before @
        COMPREPLY=( $(compgen -W "${image_list}" -S "@/" -- ${cur}) )
    fi
}

function _complete_image_manager() {
    local prev_arg=${COMP_WORDS[COMP_CWORD-1]}
    local cur_arg=${COMP_WORDS[COMP_CWORD]}
    local num_args=${#COMP_WORDS[@]}          # Including the current cursor argument
    local curr_arg_num=$(( $COMP_CWORD + 1 )) # Including the current cursor argument
    local s_words=("" "${COMP_WORDS[@]}")
    if [[ "${s_words[1]}" == "snippit" ]]; then
        s_words=("${s_words[@]:1}")   # Shift one argument
        num_args=$(( $num_args - 1 )) # Shift one argument
        curr_arg_num=$(( $curr_arg_num - 1 ))
    fi
    local operation=${s_words[2]}
    local options="-h --help list push pull ls rm mkdir"

    if [[ $snippit_update_flag == 0 ]]; then
        # snippit_update_flag=1
        snippit_image_list=$(_get_image_list)
    fi

    case "$operation" in
        "push")
            compopt -o nospace
            [[ $curr_arg_num == 3 ]] && COMPREPLY=($(compgen -f "$cur_arg"))
            [[ $curr_arg_num == 4 ]] && _complete_image_manager_path
            ;;
        "pull")
            compopt -o nospace
            [[ $curr_arg_num == 3 ]] && _complete_image_manager_path
            [[ $curr_arg_num == 4 ]] && COMPREPLY=($(compgen -f "$cur_arg"))
            ;;
        "ls" | "rm" | "mkdir")
            compopt -o nospace
            [[ $curr_arg_num == 3 ]] && _complete_image_manager_path
            ;;
        *)
            [[ $curr_arg_num == 2 ]] && COMPREPLY=( $(compgen -W "$options" -- $cur_arg) )
            ;;
    esac
}

function _complete_snippit() {
    local cur_arg=${COMP_WORDS[COMP_CWORD]}
    local options="qemu image tmux"

    case "${COMP_WORDS[1]}" in
        "qemu")
            _complete_runQEMU
            ;;
        "image")
            _complete_image_manager
            ;;
        "tmux")
            ;;
        *)
            COMPREPLY=( $(compgen -W "${options}" -- ${cur_arg}) )
            ;;
    esac
}

complete -F _complete_snippit snippit
complete -F _complete_runQEMU runQEMU.sh
complete -F _complete_image_manager local_image_manager.sh

