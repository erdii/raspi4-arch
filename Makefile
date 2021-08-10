SHELL=/bin/bash
.SHELLFLAGS=-euo pipefail -c

MIRROR := http://de5.mirror.archlinuxarm.org

export LC_ALL := POSIX

.cache/ArchLinuxARM-rpi-aarch64-latest.tar.gz:
	mkdir -p ".cache/tmp"
	curl -o ".cache/tmp/ArchLinuxARM-rpi-aarch64-latest.tar.gz" $(MIRROR)/os/ArchLinuxARM-rpi-aarch64-latest.tar.gz
	curl -o ".cache/tmp/ArchLinuxARM-rpi-aarch64-latest.tar.gz.sig" $(MIRROR)/os/ArchLinuxARM-rpi-aarch64-latest.tar.gz.sig
	# verify that signature comes from archlinux arm build pgp key:
	gpg --no-default-keyring \
		--keyring $$PWD/68B3537F39A313B3E574D06777193F152BDBE6A6.gpg \
		--verify .cache/tmp/ArchLinuxARM-rpi-aarch64-latest.tar.gz.sig
	mv ".cache/tmp/ArchLinuxARM-rpi-aarch64-latest.tar.gz" ".cache/ArchLinuxARM-rpi-aarch64-latest.tar.gz"

# this target re-executes every time... why?
# commented dependency
.cache/root: # .cache/ArchLinuxARM-rpi-aarch64-latest.tar.gz
	sudo mkdir -p ".cache/root"
	sudo su -c 'bsdtar -xpf ".cache/ArchLinuxARM-rpi-aarch64-latest.tar.gz" -C ".cache/root"'
	sudo rsync -a --no-o --no-g "root/" ".cache/root/"

# this target re-executes every time... why?
# commented dependency
setup: # .cache/root
	mountpoint ".cache/root" > /dev/null || sudo mount --bind ".cache/root" ".cache/root"
	sudo arch-chroot ".cache/root" pacman-key --init
	sudo arch-chroot ".cache/root" pacman-key --populate archlinuxarm
	sudo arch-chroot ".cache/root" pacman -Syu --noconfirm
	sudo arch-chroot ".cache/root" pacman -S sudo man-db base-devel git vim python --noconfirm
	sudo umount -R ".cache/root"

clean:
	sudo umount -R ".cache/root" || true
	[[ ! -e ".cache/root" ]] || sudo rm -rf ".cache/root"
