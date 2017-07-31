#!/bin/bash
SCRIPT_DIR=$(cd "$(dirname $0)" && pwd)
COLOR_RED='\033[1;31m'
COLOR_GREEN="\033[1;32m"
NC="\033[0;00m"

# Auto-run
cd "$SCRIPT_DIR/qemu_image"
./do_test.expect "./profile.sh --phase ./test_set/matrix" 1 "$SCRIPT_DIR/demo"
[[ $? != 0 ]] && echo -e "${COLOR_RED}Something wrong happened in the expect script${NC}"

# Parse phase of a process, speficy the PID
cd "$SCRIPT_DIR"
./snippit_ui/scripts/parse.py -i ./demo/phase/* -c

# Show in browser
cd "$SCRIPT_DIR/snippit_ui/public"
echo -e "${COLOR_GREEN}Please open your browser and enter the following URL${NC}"
python3 -m http.server

