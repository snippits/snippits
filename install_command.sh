DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export RUN_QEMU_SCRIPT_PATH=$(cd ${DIR}/qemu_image && pwd)

function _complete_runQEMU_bash() {
    local -a cur prev opts imgs
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="-h --help -g -o"
    imgs="arch vexpress realview debian"

    case "${prev}" in
        "-o")
            COMPREPLY=($(compgen -f "${cur}"))
            ;;
        *)
            COMPREPLY=( $(compgen -W "${opts} ${imgs}" -- ${cur}) )
            ;;
    esac
}

function _complete_runQEMU_zsh() {
    local -a options images
    options=('-h:Display help message and information of usage.' \
        '-g:Use gdb to run QEMU for debugging' \
        '-o:Specify the output directory for emulation' \
        )
    images=('vexpress:Run Vexpress Image (ARM)' \
        'realview:Run Realview Image (ARM)' \
        'arch:Run Arch Linux Image (ARM)' \
        'debian:Run Debian Linux Image (ARM)' \
        'x86_64:Run x86_64 Image' \
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

function _complete_snippit_bash() {
    local -a cur prev opts imgs
    cur="${COMP_WORDS[COMP_CWORD]}"
    opts="qemu"

    case ${COMP_WORDS[1]} in
        qemu)
            _complete_runQEMU_bash
            ;;
        *)
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            ;;
    esac
}

function _complete_snippit_zsh() {
    local -a qemu_images
    qemu_images=('vexpress' 'realview' 'arch' 'x86_64')
    _arguments '1: :->task'

    case $state in
        task)
            _arguments '1:task:(qemu)'
            ;;
        *)
            case $words[2] in
                qemu)
                    _complete_runQEMU_zsh
                    ;;
                phase)
                    ;;
            esac
        ;;
esac
}

function runQEMU.sh() {
    $RUN_QEMU_SCRIPT_PATH/runQEMU.sh $@
}

function snippit() {
    task=$1
    # Remove the first 'task' argument
    shift 1

    case $task in
        qemu)
            runQEMU.sh $@
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


