# Snippit
This is the main repo of snippit, containing various of tools and repos.

# Usage
1. Run `./prepare.sh` to set up the working environment
2. Run `source ./install_command.sh` to get snippit command and completions
3. Run `./demo.sh` to run a demo of snippit

# Snippit command
The __snippit command__ can be executed at any working directory. The command leads
other sub-commands to perform the actions easier.
The current version has only one sub-command, qemu.
Sample usages are:
1. `snippit qemu vexpress`
2. `snippit qemu -o ./demo vexpress`

# License
1. __qemu_vpmu__ is released under GNU Library General Public License, version 2.0
2. __qemu_image__ is released under MIT License
3. __vpmu_controller__ is released under MIT License
4. __snippit_ui__ is released under MIT License

