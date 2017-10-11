if [[ -n "$ZSH_VERSION" ]]; then
    # assume Zsh
    SNIPPIT_HOME="$(readlink -f "$(dirname "$0")")"
    source "${SNIPPIT_HOME}/zsh_comp.sh"
elif [[ -n "$BASH_VERSION" ]]; then
    # assume Bash
    SNIPPIT_HOME="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")"
    source "${SNIPPIT_HOME}/bash_comp.sh"
fi
export RUN_QEMU_SCRIPT_PATH="${SNIPPIT_HOME}/qemu_image"
export PATH="${SNIPPIT_HOME}/bin":$PATH
echo "Installed shell function - snippit. The completion of all scripts and snippit command are now available."
echo "\$SNIPPIT_HOME=${SNIPPIT_HOME}"

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
            $RUN_QEMU_SCRIPT_PATH/local_image_manager.sh $@
            ;;
        tmux)
            cd "${SNIPPIT_HOME}"
            tmuxinator local
            ;;
    esac
}

