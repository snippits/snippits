DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export RUN_QEMU_SCRIPT_PATH=$(cd ${DIR}/qemu_image && pwd)
snippit_image_list=""
snippit_update_flag=0

function _get_image_list() {
    local res=$($RUN_QEMU_SCRIPT_PATH/image_manager.sh list | awk '{print $1}')
    if [[ -n "$ZSH_VERSION" ]]; then
        # assume Zsh
        res=("${(f)res}") # Line-separated string to array

        for f in $res[2,-1]; do # Loop start from second to last element
            echo $f
        done
    elif [[ -n "$BASH_VERSION" ]]; then
        # assume Bash
        res=($res) # Line-separated string to array

        for f in "${res[@]:1}"; do # Loop start from second to last element
            echo "${f}@/"
        done
    fi
}

function _complete_runQEMU_bash() {
    local -a cur prev opts imgs
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="-h --help -g -o"
    imgs="arch vexpress debian x86_busybox x86_arch"

    case "${prev}" in
        "-o")
            COMPREPLY=($(compgen -f "${cur}"))
            ;;
        *)
            COMPREPLY=( $(compgen -W "${opts} ${imgs}"  -- ${cur}) )
            ;;
    esac
}

function _complete_image_manager_bash() {
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
        *)
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            ;;
    esac
}

function _complete_runQEMU_zsh() {
    local -a options images last_arg
    options=('-h:Display help message and information of usage.' \
        '-g:Use gdb to run QEMU for debugging' \
        '-o:Specify the output directory for emulation' \
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
        *)
            _describe -V 'values' options
            _describe -V 'values' images
            ;;
    esac
}

function _complete_image_manager_zsh() {
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
        "pull")
            [[ $num_args == 4 ]] &&  _sep_parts "($snippit_image_list)" @/
            [[ $num_args == 5 ]] &&  _alternative 'files:filenames:_files'
            ;;
        "push")
            [[ $num_args == 4 ]] &&  _alternative 'files:filenames:_files'
            [[ $num_args == 5 ]] &&  _sep_parts "($snippit_image_list)" @/
            ;;
        *)
            _describe -V 'values' options
            _describe -V 'values' actions
            ;;
    esac
}

function _complete_snippit_bash() {
    local -a cur prev opts imgs
    cur="${COMP_WORDS[COMP_CWORD]}"
    opts="qemu image"

    case ${COMP_WORDS[1]} in
        qemu)
            _complete_runQEMU_bash
            ;;
        image)
            _complete_image_manager_bash
            ;;
        *)
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            ;;
    esac
}

function _complete_snippit_zsh() {
    _arguments '1: :->task'

    case $state in
        task)
            _arguments '1:task:(qemu image)'
            ;;
        *)
            case $words[2] in
                qemu)
                    _complete_runQEMU_zsh
                    ;;
                image)
                    _complete_image_manager_zsh
                    ;;
                phase)
                    ;;
            esac
        ;;
esac
}

function snippit() {
    task=$1
    # Remove the first 'task' argument
    shift 1
    # Reset flag so that next completion will reload variables
    snippit_update_flag=0

    case $task in
        qemu)
            $RUN_QEMU_SCRIPT_PATH/runQEMU.sh $@
            ;;
        image)
            $RUN_QEMU_SCRIPT_PATH/image_manager.sh $@
            ;;
    esac
}

if [[ -n "$ZSH_VERSION" ]]; then
    # assume Zsh
    compdef _complete_snippit_zsh snippit
    compdef _complete_runQEMU_zsh runQEMU.sh
    autoload colors && colors
elif [[ -n "$BASH_VERSION" ]]; then
    # assume Bash
    complete -F _complete_snippit_bash snippit
    complete -F _complete_runQEMU_bash runQEMU.sh
fi


