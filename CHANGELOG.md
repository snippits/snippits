## [Unreleased]

## [0.8.2] - 2017-10-11
### Added
- (qemu_vpmu) Add extra local buffers for GPU
- (qemu_vpmu) Add new RingBuffer implementation in C++14 style
- (qemu_vpmu) Add new async callback interface and fix all previous sync issues
- (snippits) Add image path completion on bash shell (kinda work)
- (snippits) Add `comp_helper.sh` for image path completion codes
- (snippits) Add tmux monitor UI interface

### Changed
- (qemu_image) Solve the bug of remaining character of expect script
- (qemu_image) New script and image management system
- (qemu_vpmu) Upgrade to QEMU 2.10.1
- (qemu_vpmu) Support per-core profiling counter snapshot
- (qemu_vpmu) Support per-process profiling counter collection
- (qemu_vpmu) Rename/Add the series of vpmu::host::get_timestamp_ns/_us/_ms
- (qemu_vpmu) Remove machine specific VPMU device hook. Enabled on all machines
- (qemu_vpmu) Enable tracing of unmap for current regions with full map output
- (qemu_vpmu) Refactor the VPMU stream interface
- (qemu_vpmu) Fix several bugs
- (vpmu_controller) Fix undefined copy_to_user() in newer kernel headers
- (snippits) Update to new API format of image management to completion system

## [0.8.1] - 2017-07-31
### Changed
- (qemu_vpmu) Refactor API of template output and add new file dump
- (qemu_vpmu) Show all mapped memory region in vm_maps
- (qemu_vpmu) Fix wrong PC address on ARM function callback registration
- (snippits) Fix of submodule
- (snippits) Update the demo.sh
- (snippit_ui) Fix parse.py for files without line number

## [0.8.0] - 2017-07-27
### Added
- (qemu_vpmu) Add MProtect and MUnmap kernel symbols
- (qemu_vpmu @ 15b5155) Complete user process function tracking and callbacks
- (qemu_vpmu) Add new function-map.hpp to provide callback function interface
- (qemu_vpmu) Add process memory map and trace the caller of mmap in user process
- (qemu_vpmu) Add VPMU_CFLAGS and CXXFLAGS in config-host.mak for customizations
- (qemu_vpmu) Replace CodeRange by the new class, Pair_beg_end, which is simpler
- (qemu_vpmu) Add several minor features
- (qemu_vpmu) Able to trace a script with all executables run by the script
- (qemu_image) Solve serial terminal problems of column width and special chars
- (qemu_image) Update image to version 3
- (qemu_image) Install more default binaries and libraries in x86_busybox image
- (vpmu_controller) Add new vpmu-perf command for easier and better control
- (vpmu_controller) Add support (parser) for profiling a script
- (vpmu_controller) Add ELF parser to identify static/dynamic linked info.
- (vpmu_controller) Add struct VPMUBinary for storing binary object info.
- (vpmu_controller) Update minor features

### Changed
- (snippits) Fix the order of arguments in Makefile in external/mbrfs
- (snippits) Ask VPMU debug config only when config does not set
- (qemu_vpmu) Make x86 CPU run on VPMU world clock
- (qemu_vpmu) Refactor MMAP to ET_Region and complete the tracing
- (qemu_vpmu) Refactor all event tracing interfaces and codes
- (qemu_vpmu) Refactor ET_Process and ET_Program
- (qemu_vpmu) Refactor string/file functions in vpmu::utils to vpmu::str and vpmu::file
- (qemu_vpmu) Fix wrong calling convention on x86 4th argument
- (qemu_vpmu) Fix several bugs
- (qemu_vpmu @ bc9ef91) Fix walk count number and line mapping on x86
- (qemu_vpmu) Fix YCM config
- (qemu_vpmu) Rewrite walk count functions for each mapped memory region
- (qemu_vpmu @ 6758ff1) Keep the consistency of #ifndef of headers and add #pragma once for speed
- (qemu_image) Fix `mount -o ro` fail when dirty log exists in the disk image
- (qemu_image) Rename image_manager.sh -> local_image_manager.sh to make a distinction from images folder
- (vpmu_controller) Refactor/clean the codes (heavely)
- (vpmu_controller) Fix bugs of "../" relative path and "not found" libraries
- (vpmu_controller) Solve the real path and symbolic link problem
- (vpmu_controller) several bugs fixed

## [0.7.6] - 2017-07-05
### Added
- (snippits) Add open source projects for supporting user-level mount (fuse)
- (snippits) Add mbrfuse and ext4fuse projects
- (snippits) Add MBR support on path completion (zsh only)
- (snippits) Try to download ARM compiler in prepare.sh
- (qemu_image) Add MBR disk image support

### Changed
- (snippits) Fix umount bug if user aborts completion
- (qemu_vpmu) Fix several bugs
- (qemu_image) Fix bug when cleaning rootfs might rm all files of last mounted image
- (qemu_image) Mount as readonly when write permission is not needed


## [0.7.5] - 2017-07-02
### Added
- (qemu_image) Add query command for completion system
- (snippits) Add completion of target image path (zsh only)
- (snippits) Add DEBUG=on option for configuring QEMU when running prepare_all.sh
- (snippits) Add change log

### Changed
- (qemu_vpmu) remove only generated files/folders to avoid deleting user files.
- (qemu_image) Print more than one level directory when printing image list.
- (qemu_image) Fix several minor behavior inconsistency and bugs.
- (qemu_image) Support spaces in path.
- (qemu_image) Move image related stuffs to images folder.
- (snippits) Refactor codes (including consistent argument parser between bash and zsh).
- (snippits) Separate codes of two completion systems.
- (snippits) Fix several minor bugs.
- (snippits) Use shallow submodule clone in prepare_all.sh


## [0.7.2] - 2017-07-1
### Added
- (qemu_image) Add sha256sums checks to downloaded pre-built images.
- (qemu_image) Add image_manager.sh script
- (qemu_image) Update pre-built images
- (snippits) Add snippit sub-command - image
- (snippits) Add more completion options for sub-command - qemu

### Changed
- (qemu_image) Rewrite downloaded.sh.
- (qemu_image) Update the link to Linaro ARM compiler
- (snippits) Fix demo.sh code
- (snippits) Change default ARM compiler from gnueabihf to gnueabi
- (snippits) Fix links and add error checks in prepare_all.sh


## [0.7.0] - 2017-06-18
### Added
- (qemu_vpmu) Upgrade to QEMU 2.9
- (qemu_vpmu) Multi-core emulation support (timing and phases are still in progress)
- (qemu_vpmu) Massively refactor codes and folders
- (qemu_vpmu) Many bugs fixed
- (qemu_vpmu) Kernel TSS (Thread State Segment) support
- (qemu_vpmu) Device driver now supports Linux 3.0 - latest
- (qemu_vpmu) Add variable checks for debugging

### Changed
- (qemu_vpmu @ c706765) Refactor VPMUInsn and change API of VPMUStream
- (qemu_vpmu) Rewrite whole VPMUSnapshot with operator overloading
- (qemu_vpmu @ 42b2010) Redefine all interface of VPMUPacket::Data
- (qemu_vpmu) CPU timing model is now using per-core counter
- (qemu_vpmu) Fix user_mode detection in phase when running on SMP
- (qemu_vpmu) Refactor all the codes related to kernel events. (huge changes)
- (qemu_vpmu) Fix get_input_arg() issues/bugs across OSs and platforms
- (qemu_vpmu) Refactor codes of op-vpmu.c and use new writing style on conditions
- (qemu_vpmu) Merge many i386 specific codes with arm specific codes. The abstract interface uses architecture dependent variable with macro definition.
- (qemu_vpmu) Fix Doxygen file
- (qemu_vpmu) Refactor vpmu_tlb_get_host_addr()
- (qemu_vpmu @ 557ed74) Fix x86_64 SMP issue on event tracking
- (qemu_vpmu) Disable SET/Phase when enabling kvm
- (qemu_vpmu) Fix the vpmu device data access issue on 64 bits platform

## [0.15.2] - 2017-05-23
### Added
- Many updates :D (Version number is just a respect to QEMU)
- Better web UI with react.js


## [0.15.0] - 2017-01-26
- Initial commit (Version number is just a respect to QEMU)
- Support only single core system mode
- ARM timing model support
- Multi-Model support
- JIT Model Selection support
- Event tracing support
- Phase detection support



