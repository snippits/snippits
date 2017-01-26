#!/bin/bash
SCRIPT_DIR=$(cd "$(dirname $0)" && pwd)
COLOR_GREEN="\033[1;32m"
NC="\033[0;00m"

function init_git(){
    cd $SCRIPT_DIR
    git submodule update --init qemu_vpmu qemu_image snippit_ui
}

function prepare_qemu_vpmu() {
    echo "##########################################################"
    echo -e "#    ${COLOR_GREEN}Prepare qemu_vpmu${NC}"
    echo "##########################################################"

    cd $SCRIPT_DIR/qemu_vpmu
    mkdir -p build
    cd build
    ../configure '--target-list=arm-softmmu' '--enable-vpmu' '--enable-vpmu-set'
    make -j8
}

function prepare_qemu_image() {
    echo "##########################################################"
    echo -e "#    ${COLOR_GREEN}Prepare qemu_image${NC}"
    echo "##########################################################"

    cd $SCRIPT_DIR/qemu_image
    ./download.sh
}

function prepare_snippit_ui() {
    echo "##########################################################"
    echo -e "#    ${COLOR_GREEN}Prepare snippit_ui${NC}"
    echo "##########################################################"

}

init_git
prepare_qemu_vpmu
prepare_qemu_image
prepare_snippit_ui

source $SCRIPT_DIR/install_command.sh

