# Snippit
This is the main repo of snippit, containing various of tools and repos. Please use this to make sure the versions of all submodules are in consistent.

# Quick Start Demo
0. Run `pip3 install klein numpy anytree logzero sh` to install Python prerequisite.
1. Run `./prepare_all.sh` to set up the working environment.
2. Run `source ./install_command.sh` to get snippit command and completions
3. Run `./demo.sh` to run a demo of snippit
4. Open browser and enter URL [http://127.0.0.1:5000/](http://127.0.0.1:5000/)

![Image of Snippit](https://github.com/snippits/snippit_ui/blob/master/images/snippit.png?raw=true "Sample Image")

# Change Log
## Features of 0.8
1. Full support of process virtual memory tracing, i.e. mmap
2. __FBT__ (Function Boundary Tracing) callbacks (Similar to DTrace but in hard code)
3. Add more features to support SMP profiling with multiple processes
4. Able to trace a script with all commands executed by the script
5. __Better, stronger, cleaner__ codes of event tracing functionalities
6. Better default terminal configurations, support special keys and full window width text
7. More default binaries and libraries in x86_busybox image
8. Brand new `vpmu-perf` command for easier and better control in command line
9. Add mbrfuse and ext4fuse projects as external tools
10. Able to complete the path in the image when using `snippit image` command
11. Many bugs fixed
12. Add sha256sums checks for downloaded pre-built images

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
5. TBA

# Important Requirements
* gcc/g++ version >= __4.9__
* [Highly recommand] clang/clang++ LLVM
* ARM cross compiler gcc/g++ version >= 4.8 [linaro gcc 4.9](https://releases.linaro.org/components/toolchain/binaries/4.9-2017.01/arm-linux-gnueabi/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabi.tar.xz).
* Beta version supports only ARM target system. x86 would be supported in the future.

# Snippit command
The __snippit command__ can be executed at any working directory. The command leads
other sub-commands to perform the actions easier.
The current version has only one sub-command, qemu.
Sample usages are:
1. `snippit qemu vexpress`
2. `snippit qemu vexpress -o ./demo`
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

## Completion for Disk Images
Please install `fusermount` and `fuse` libraries in order to have completion for paths in disk images.
The completion system supports __e2fs__ (ext2, ext3, ext4) and images with MBR partition table. (currently zsh only)
For example: when typing \<TAB\> in `snippit image ls rootfs@/`, the images will be mounted in user mode and the possible paths will be shown for file path completion.

# License
1. __qemu_vpmu__ is released under GNU Library General Public License, version 2.0
2. __qemu_image__ is released under MIT License
3. __vpmu_controller__ is released under MIT License
4. __snippit_ui__ is released under MIT License
5. __external__: Please refer to the licenses in each directories.

