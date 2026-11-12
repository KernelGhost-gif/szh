.PHONY: all validate initramfs boot-test test clean

all: initramfs

validate:
	./scripts/validate-distro.sh

initramfs:
	./scripts/build-initramfs.sh

boot-test: initramfs
	./scripts/qemu-smoke-test.sh

test: boot-test

clean:
	rm -rf build
