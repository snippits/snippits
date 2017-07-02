# Snippit
This is the main repo of snippit, containing various of tools and repos. Please use this to make sure the versions of all submodules are in consistent.

# Change Log
## Features of 0.7
1. Upgrade to QEMU 2.9
2. Multi-core emulation support (timing and phases are still in progress)
3. Massively refactor codes and folders
4. Many bugs fixed
5. Kernel TSS (Thread State Segment) support
6. Device driver now supports Linux 3.0 - latest

## Up Comming Features
1. Function call stack tracking
2. Robust phase detection for general program
3. Phase bottleneck analysis
4. Heterogeneous-friendliness prediction
5. FBT (Function Boundary Tracing) callbacks (Similar to DTrace)
6. TBA

# Important Requirements
* gcc/g++ version >= __4.9__
* [Highly recommand] clang/clang++ LLVM
* ARM cross compiler gcc/g++ version >= 4.8 [linaro gcc 4.9](https://releases.linaro.org/components/toolchain/binaries/4.9-2017.01/arm-linux-gnueabi/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabi.tar.xz).
* Beta version supports only ARM target system. x86 would be supported in the future.

# Usage
1. Run `./prepare.sh` to set up the working environment. To enable debug mode of QEMU, run `DEBUG=on ./prepare_all.sh` instead.
2. Run `source ./install_command.sh` to get snippit command and completions
3. Run `./demo.sh` to run a demo of snippit

# Snippit command
The __snippit command__ can be executed at any working directory. The command leads
other sub-commands to perform the actions easier.
The current version has only one sub-command, qemu.
Sample usages are:
1. `snippit qemu vexpress`
2. `snippit qemu -o ./demo vexpress`
3. `snippit image list`
4. `snippit image ls rootfs@/root`

# Change window size
Sometime the windows size (granularity) would affect the results and make it hard to read.
Adjusting the window size is a way to inspect your code. Future version would be able to
adjust window size offline. The current version can only do this when running program.
Window size is assigned by environment variable in the unit of kilo instructions.
Ex:
* 200k instructions (default size) `PHASE_WINDOW_SIZE=200 snippit qemu vexpress`
* 500k instructions `PHASE_WINDOW_SIZE=500 snippit qemu vexpress`

One can also assign __env__ at any script.
Ex:
* `PHASE_WINDOW_SIZE=200 make execute -j8` in __qemu_vpmu/build__
* `PHASE_WINDOW_SIZE=100 ./runQEMU.sh vexpress` in __qemu_image__

# Completion System
The `install_command.sh` support completions for all main scripts and `snippit` command. Both __bash__ and __zsh__ are supported.

In addition, the completion in __zsh__ perform much better and provide full support in image sub-command, i.e. path completion for target image(ext2, ext3, ext4, cpio).

## e2fs filesystem support
Please install `fusermount` and `ext4fuse` commands for e2fs filesystem completion support.
The completion system is built on user level with read-only permission, which means it's safe.
If you cannot find `ext4fuse` in your package manager, please refer to [gerard/ext4fuse](https://github.com/gerard/ext4fuse).

# License
1. __qemu_vpmu__ is released under GNU Library General Public License, version 2.0
2. __qemu_image__ is released under MIT License
3. __vpmu_controller__ is released under MIT License
4. __snippit_ui__ is released under MIT License

