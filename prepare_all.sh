#!/bin/bash
SCRIPT_DIR=$(cd "$(dirname $0)" && pwd)
COLOR_GREEN="\033[1;32m"
NC="\033[0;00m"

function init_git(){
    cd $SCRIPT_DIR
    git submodule update --init qemu_vpmu qemu_image snippit_ui vpmu_controller
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
    arm-linux-gnueabi-gcc -g ./matrix_mul.c -o ./matrix
    sudo cp ./matrix ./rootfs/root/test_set/
    ./cpioBuild.sh
}

function prepare_vpmu_controller() {
    echo "##########################################################"
    echo -e "#    ${COLOR_GREEN}Prepare vpmu_controller${NC}"
    echo "##########################################################"
    cd $SCRIPT_DIR/vpmu_controller
    make
}

function prepare_snippit_ui() {
    echo "##########################################################"
    echo -e "#    ${COLOR_GREEN}Prepare snippit_ui${NC}"
    echo "##########################################################"

}

function test_binary_dep() {
    vpmu_clang_found=$(command -v clang++ 2> /dev/null)
    vpmu_arm_gcc_found=$(command -v arm-linux-gnueabi-gcc 2> /dev/null)

    if test "$vpmu_clang_found" = ""; then # Not found
        echo -e "\033[1;31m" \
            "clang, clang++ is not found in \$PATH. Clang/LLVM provides much better optimizations in some cases.\n" \
            "  We strongly suggest to use clang for compiling VPMU module for the best performance!\n" \
            "According to our experiments, the clang compiler optimizes better in some cases." \
            "\033[0;00m\n"
    fi

    if test "$vpmu_arm_gcc_found" = ""; then # Not found
        echo -e "\033[1;31m" \
            "arm-linux-gnueabi-gcc is not found in \$PATH.\n" \
            "  Please download it and set in the \$PATH" \
            "\033[0;00m\n"
        echo "Linaro ARM gcc:"
        echo "https://releases.linaro.org/14.11/components/toolchain/binaries/arm-linux-gnueabi/gcc-linaro-4.9-2014.11-x86_64_arm-linux-gnueabi.tar.xz"
        exit 1
    fi
}

test_binary_dep
init_git
prepare_qemu_vpmu
prepare_qemu_image
prepare_vpmu_controller
prepare_snippit_ui

