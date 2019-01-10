#!/bin/bash
# Copyright (c) 2017, Medicine Yeh

WORK_DIR=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")/../")
COLOR_RED='\033[1;31m'
COLOR_GREEN='\033[1;32m'
COLOR_YELLOW='\033[1;33m'
NC='\033[0;00m'

function ask_response()
{
    while true; do
        read -p "${1}`echo $'\ndefault '`[${2}]?" yn
        case $yn in
            [Yy]* ) echo "y"; break;;
            [Nn]* ) echo "n"; break;;
            "" ) echo "$2"; break;;
        esac
    done
}

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
    cd "$WORK_DIR"
    # Shallow clone to save time
    git submodule update --init --depth 10
    [[ $? != 0 ]] && print_message_and_exit "git submodule"
}

function prepare_qemu_vpmu() {
    echo -e "#    ${COLOR_GREEN}Prepare qemu_vpmu${NC}"

    mkdir -p "$WORK_DIR/qemu-vpmu/build"
    cd "$WORK_DIR/qemu-vpmu/build"
    if [[ ! -f ./config-host.mak ]]; then
        # Only do configure when it is the first time executing this
        local enable_vpmu_debug=$(ask_response "Enable QEMU VPMU debug message? (y/n)" "n")
        local options=(--python=$(which python2)
            --target-list=arm-softmmu,x86_64-softmmu
            --enable-vpmu
            --enable-vpmu-set
        )
        [[ "$enable_vpmu_debug" == "y" ]] && options+=(--enable-vpmu-debug)
        ../configure "${options[@]}"
        [[ $? != 0 ]] && print_message_and_exit "QEMU configure script"
    fi
    make -j$(nproc)
    [[ $? != 0 ]] && print_message_and_exit "QEMU make"
}

function prepare_qemu_image() {
    echo -e "#    ${COLOR_GREEN}Prepare qemu_image${NC}"

    pip3 install sh

    cd "$WORK_DIR/qemu-image"
    ./download.sh
    cd "$WORK_DIR/qemu-image/guest-images"
    [[ $? != 0 ]] && print_message_and_exit "Download pre-built image"
    arm-linux-gnueabi-gcc -g ./matrix_mul.c -o ./matrix
    [[ $? != 0 ]] && print_message_and_exit "arm-linux-gnueabi-gcc"
    ${WORK_DIR}/qemu-image/image_manager.py push ./matrix arm/busybox/rootfs.cpio@/root/test_set/
    [[ $? != 0 ]] && print_message_and_exit "./image_manager.sh push"
}

function prepare_vpmu_controller() {
    echo -e "#    ${COLOR_GREEN}Prepare vpmu_controller${NC}"
    cd "$WORK_DIR/vpmu-controller"
    make
    [[ $? != 0 ]] && print_message_and_exit "Make vpmu controller"
}

function prepare_snippit_ui() {
    echo -e "#    ${COLOR_GREEN}Prepare snippit_ui${NC}"

    pip3 install --user klein numpy anytree logzero
}

function prepare_snippit_external() {
    echo -e "#    ${COLOR_GREEN}Prepare external tools${NC}"
    mkdir -p "$WORK_DIR/external/bin"

    if check_command mbrfs; then
        cd "$WORK_DIR/external/mbrfs"
        make
        [[ $? != 0 ]] && print_message_and_exit "make external/mbrfs"
        cp "$WORK_DIR/external/mbrfs/mbrfs" "$WORK_DIR/external/bin/mbrfs"
    fi
    if check_command ext4fuse; then
        cd "$WORK_DIR/external/ext4fuse"
        make
        [[ $? != 0 ]] && print_message_and_exit "make external/ext4fuse"
        cp "$WORK_DIR/external/ext4fuse/ext4fuse" "$WORK_DIR/external/bin/ext4fuse"
    fi
}

function test_binary_dep() {
    local cmds=(gcc git make wget curl sudo rsync python3 pip3)

    for c in ${cmds[*]}; do
        check_command "$c" && echo -e "Required command ${COLOR_RED}${c}${NC} not found"
    done

    if check_command expect; then # Not found
        echo -e "${COLOR_RED}" \
            "Binary 'expect' is not found. Please install it with your package manager." \
            "${NC}\n"
    fi

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

        if [[ $(ask_response "Download Linaro ARM compiler to ./external? (y/n)" "n") == "y" ]]; then
            local file_path="${WORK_DIR}/external/gcc-linaro-4.9-gnueabi.tar.xz"
            local dir_path="${file_path%%.tar*}"
            local link="https://releases.linaro.org/components/toolchain/binaries/4.9-2017.01/arm-linux-gnueabi/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabi.tar.xz"

            [[ ! -f "$file_path" ]] && wget "$link" -O "$file_path"
            mkdir -p "$dir_path"
            echo -e "${COLOR_GREEN}decompress file $file_path${NC}"
            tar -xf "$file_path" -C "$dir_path" --strip-components 1
            echo -e "${COLOR_YELLOW}Please copy and paste the following line to your ~/.bashrc or ~/.zshrc${NC}"
            echo "export PATH=\$PATH:${dir_path}/bin"
            echo -e "\n\n"
            # Make it temporary work for this script.
            export PATH=${dir_path}/bin:$PATH
        else
            echo "Linaro ARM gcc can be found here. Please downlaod it and add it to the \$PATH."
            echo "https://releases.linaro.org/components/toolchain/binaries/4.9-2017.01/arm-linux-gnueabi/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabi.tar.xz"
            exit 1
        fi
    fi
}

test_binary_dep
init_git
prepare_qemu_vpmu
prepare_qemu_image
prepare_vpmu_controller
prepare_snippit_ui
prepare_snippit_external
