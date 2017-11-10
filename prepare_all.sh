#!/bin/bash
# Copyright (c) 2017, Medicine Yeh

SCRIPT_DIR=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
COLOR_RED='\033[1;31m'
COLOR_GREEN='\033[1;32m'
COLOR_YELLOW='\033[1;33m'
NC='\033[0;00m'

function ask_response()
{
    local user_decision=""

    if [[ -n "$ZSH_VERSION" ]]; then
        read user_decision\?"${1}`echo $'\n> '`default[${2}]?"
    else
        read -p "${1}`echo $'\ndefault '`[${2}]? " user_decision
    fi

    [[ "$user_decision" != "" ]] && echo "$user_decision"
    [[ "$user_decision" == "" ]] && echo "$2"
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
    cd "$SCRIPT_DIR"
    # Shallow clone to save time
    git submodule update --init --depth 10
    [[ $? != 0 ]] && print_message_and_exit "git submodule"
}

function prepare_qemu_vpmu() {
    echo -e "#    ${COLOR_GREEN}Prepare qemu_vpmu${NC}"

    mkdir -p "$SCRIPT_DIR/qemu_vpmu/build"
    cd "$SCRIPT_DIR/qemu_vpmu/build"
    if [[ ! -f ./config-host.mak ]]; then
        local enable_vpmu_debug=$(ask_response "Enable QEMU VPMU debug message? (y/n)" "n")
        # Only do configure when it is the first time executing this
        if [[ "$enable_vpmu_debug" == "n" ]]; then
            echo "VPMU debug option is off"
            ../configure '--target-list=arm-softmmu x86_64-softmmu' '--enable-vpmu' '--enable-vpmu-set'
        else
            echo "VPMU debug option is on"
            ../configure '--target-list=arm-softmmu x86_64-softmmu' '--enable-vpmu' '--enable-vpmu-set' '--enable-vpmu-debug'
        fi
    fi
    [[ $? != 0 ]] && print_message_and_exit "QEMU configure script"
    make -j8
    [[ $? != 0 ]] && print_message_and_exit "QEMU make"
}

function prepare_qemu_image() {
    echo -e "#    ${COLOR_GREEN}Prepare qemu_image${NC}"

    cd "$SCRIPT_DIR/qemu_image"
    ./download.sh
    cd "$SCRIPT_DIR/qemu_image/guest-images"
    [[ $? != 0 ]] && print_message_and_exit "Download pre-built image"
    arm-linux-gnueabi-gcc -g ./matrix_mul.c -o ./matrix
    [[ $? != 0 ]] && print_message_and_exit "arm-linux-gnueabi-gcc"
    ../image_manager.sh push ./matrix rootfs.cpio@/root/test_set/
    [[ $? != 0 ]] && print_message_and_exit "./image_manager.sh push"
}

function prepare_vpmu_controller() {
    echo -e "#    ${COLOR_GREEN}Prepare vpmu_controller${NC}"
    cd "$SCRIPT_DIR/vpmu_controller"
    make
    [[ $? != 0 ]] && print_message_and_exit "Make vpmu controller"
}

function prepare_snippit_ui() {
    echo -e "#    ${COLOR_GREEN}Prepare snippit_ui${NC}"

}

function prepare_snippit_external() {
    echo -e "#    ${COLOR_GREEN}Prepare external tools${NC}"

    if check_command mbrfs; then
        cd "$SCRIPT_DIR/external/mbrfs"
        make
        [[ $? != 0 ]] && print_message_and_exit "make external/mbrfs"
        cp "$SCRIPT_DIR/external/mbrfs/mbrfs" "$SCRIPT_DIR/bin"
    fi
    if check_command ext4fuse; then
        cd "$SCRIPT_DIR/external/ext4fuse"
        make
        [[ $? != 0 ]] && print_message_and_exit "make external/ext4fuse"
        cp "$SCRIPT_DIR/external/ext4fuse/ext4fuse" "$SCRIPT_DIR/bin"
    fi
}

function test_binary_dep() {
    local cmds=(gcc git make wget curl sudo rsync)

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
            local file_path="${SCRIPT_DIR}/external/gcc-linaro-4.9-gnueabi.tar.xz"
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

