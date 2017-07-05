# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]


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



