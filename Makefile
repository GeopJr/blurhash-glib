.PHONY: all install uninstall build test

all: build

build:
	meson setup builddir .
	meson compile -C builddir

install:
	meson install -C builddir

uninstall:
	sudo ninja uninstall -C builddir

test:
	meson test -C builddir
