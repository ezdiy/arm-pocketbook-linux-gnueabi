CROSS ?= arm-pocketbook-linux-gnueabi
CROSSPATH = $(shell pwd)/$(CROSS)
CROSSGCC = $(CROSSPATH)/bin/$(CROSS)-gcc
CHOST = $(CROSS)
export CHOST

SYSROOT=$(shell pwd)/sysroot
RSYSROOT=$(CROSSPATH)/$(CROSS)/sysroot
LIB=$(SYSROOT)/usr/local/lib
RLIB=$(RSYSROOT)/usr/local/lib
INC=$(SYSROOT)/usr/local/include

ICU=libicuuc.so.58
ICUSRC=$(shell pwd)/icu/icu4c/source
ICUTARGET=$(LIB)/$(ICU)

SSL=libssl.so.1.0.0
SSLSRC=$(shell pwd)/openssl
SSLTARGET=$(LIB)/$(SSL)

ZLIB=libz.so.1.2.11
ZLIBSRC=$(shell pwd)/zlib
ZLIBTARGET=$(LIB)/$(ZLIB)

CURSES=libncurses.so.6.0
CURSESVER=ncurses-6.0
CURSESSRC=$(shell pwd)/$(CURSESVER)
CURSESTARGET=$(LIB)/$(CURSES)

#Configure targets you want in here
TARGETS=
#TARGETS += $(ICUTARGET)
TARGETS += $(ZLIBTARGET)
TARGETS += $(SSLTARGET)
TARGETS += $(CURSESTARGET)

all: $(TARGETS)

clean:
	rm -rf $(SYSROOT)/usr/local
	(cd zlib && make clean)
	(cd openssl && make clean)
	(cd $(CURSESVER) && make clean)
	rm -rf release
	rm -rf icu-host icu-target

icu-host:
	(mkdir -p icu-host && cd icu-host && $(ICUSRC)/configure --with-data-packaging=archive --enable-static --disable-shared && make -j)
icu-target: icu-host $(CROSS)-gcc
	(mkdir -p icu-target && cd icu-target && $(ICUSRC)/configure --with-data-packaging=archive --host $(CROSS) --prefix=/usr/local --with-cross-build=$(shell pwd)/icu-host && make -j)

$(ICUTARGET): icu-target 
	(cd icu-target && make DESTDIR=$(SYSROOT) install)

$(SSLTARGET): $(ZLIBTARGET) $(CROSSGCC)
	(cd openssl && ./Configure --install_prefix=$(SYSROOT) --cross-compile-prefix=$(CROSS)- --prefix=/usr/local --with-zlib-include=$(INC) --with-zlib-lib=$(LIB) linux-armv4 shared no-engine zlib-dynamic && make -j && make install_sw)
	rm -f $(LIB)/*.a

$(ZLIBTARGET): $(CROSSGCC)
	(cd zlib && ./configure --prefix=/usr/local && make shared -j && make DESTDIR=$(SYSROOT) install)
	rm -f $(LIB)/*.a

$(CURSESSRC):
	wget -c https://ftp.gnu.org/pub/gnu/ncurses/$(CURSESVER).tar.gz
	tar -xvzf $(CURSESVER).tar.gz
	cd $(CURSESSRC) && patch -p1 < ../ncurses-5.9-gcc-5.patch

$(CURSESTARGET): $(CURSESSRC) $(CROSSGCC)
	(cd $(CURSESSRC) && ./configure --host=$(CROSS) --with-shared --prefix=/usr/local && make -j && cd ncurses && make DESTDIR=$(SYSROOT) install)

$(CROSSGCC):
	echo 'Build the toolchain with: ct-ng build'
	echo 'Then export PATH=$$PATH:$(CROSSPATH)/bin'

release: $(TARGETS) $(CROSSGCC)
	mkdir -p release
	cp -a $(CROSSPATH) release/
	chmod +w -R $(RSYSROOT)
	cp -a sysroot/* $(RSYSROOT)
	chmod +w -R $(RSYSROOT)
	./libgen.sh
	rm -f $(RLIB)/*.a
	for n in $(RLIB)/*.so.*.*; do chmod 0755 $$n; $(CROSS)-strip $$n; done

