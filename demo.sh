#!/bin/bash
SCRIPT_DIR=$(cd "$(dirname $0)" && pwd)
COLOR_GREEN="\033[1;32m"
NC="\033[0;00m"

function run_demo() {
    cd $SCRIPT_DIR/qemu_image
    ./do_test.expect "./profile.sh --phase ./test_set/matrix" 1 $SCRIPT_DIR/demo
    cd $SCRIPT_DIR
    ./snippit_ui/scripts/parse.py -i ./demo/phase/*
    cd $SCRIPT_DIR/snippit_ui/public
    python3 -m http.server &
}

run_demo

echo "It's now your turn"
sleep 3
cd $SCRIPT_DIR
source $SCRIPT_DIR/install_command.sh
snippit qemu vexpress

