#!/bin/bash
SCRIPT_DIR=$(cd "$(dirname $0)" && pwd)
COLOR_RED='\033[1;31m'
COLOR_GREEN='\033[1;32m'
COLOR_YELLOW='\033[1;33m'
NC='\033[0;00m'

# NOTE: return 0 when command not found and return 1 when found
function check_command() {
    command_found=$(command -v "$1" 2> /dev/null)
    if [[ "$command_found" == "" ]]; then
        return 0 # NOT found
    else
        return 1 # Found
    fi
}

function print_message_and_exit() {
    echo "Something went wrong?"
    echo -e "Possibly related to ${COLOR_YELLOW}${1}${NC}"
    exit 4
}

function init_git(){
    cd $SCRIPT_DIR
    git submodule update --init qemu_vpmu qemu_image snippit_ui vpmu_controller
    [[ $? != 0 ]] && print_message_and_exit "git submodule"
}

function prepare_qemu_vpmu() {
    echo -e "#    ${COLOR_GREEN}Prepare qemu_vpmu${NC}"

    cd $SCRIPT_DIR/qemu_vpmu
    mkdir -p build
    cd build
    if [[ ! -f ./config-host.mak ]]; then
        # Only do configure when it is the first time executing this
        ../configure '--target-list=arm-softmmu x86_64-softmmu' '--enable-vpmu' '--enable-vpmu-set'
    fi
    [[ $? != 0 ]] && print_message_and_exit "QEMU configure script"
    make -j8
    [[ $? != 0 ]] && print_message_and_exit "QEMU make"
}

function prepare_qemu_image() {
    echo -e "#    ${COLOR_GREEN}Prepare qemu_image${NC}"

    cd $SCRIPT_DIR/qemu_image/images
    ./download.sh
    [[ $? != 0 ]] && print_message_and_exit "Download pre-built image"
    ./extract_cpio.sh
    arm-linux-gnueabi-gcc -g ./matrix_mul.c -o ./matrix
    [[ $? != 0 ]] && print_message_and_exit "arm-linux-gnueabi-gcc"
    sudo cp ./matrix ./rootfs/root/test_set/
    ./cpioBuild.sh
}

function prepare_vpmu_controller() {
    echo -e "#    ${COLOR_GREEN}Prepare vpmu_controller${NC}"
    cd $SCRIPT_DIR/vpmu_controller
    make
    [[ $? != 0 ]] && print_message_and_exit "Make vpmu controller"
}

function prepare_snippit_ui() {
    echo -e "#    ${COLOR_GREEN}Prepare snippit_ui${NC}"

}

function test_binary_dep() {
    local cmds=(gcc git make wget curl sudo)

    for c in ${cmds[*]}; do
        check_command "$c" && echo -e "Required command ${COLOR_RED}${c}${NC} not found"
    done

    if check_command clang++ || check_command clang; then # Not found
        echo -e "${COLOR_YELLOW}" \
            "[OPTIONAL] " \
            "clang, clang++ is not found in \$PATH. Clang/LLVM provides much better optimizations in some cases.\n" \
            "  We strongly suggest to use clang for compiling VPMU module for the best performance!\n" \
            "According to our experiments, the clang compiler optimizes better in some cases." \
            "${NC}\n"
    fi

    if check_command arm-linux-gnueabi-gcc || check_command arm-linux-gnueabi-g++; then # Not found
        echo -e "${COLOR_RED}" \
            "[REQUIRED]" \
            "arm-linux-gnueabi-gcc is not found in \$PATH.\n" \
            "  Please download it and set in the \$PATH" \
            "${NC}\n"
        echo "Please download Linaro ARM gcc from here:"
        echo "https://releases.linaro.org/components/toolchain/binaries/4.9-2017.01/arm-linux-gnueabi/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabi.tar.xz"
        exit 1
    fi
}

test_binary_dep
init_git
prepare_qemu_vpmu
prepare_qemu_image
prepare_vpmu_controller
prepare_snippit_ui

