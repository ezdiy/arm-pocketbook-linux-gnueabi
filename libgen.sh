#!/bin/bash
CROSS=arm-pocketbook-linux-gnueabi
function gen() {
SECT=""
cat $1 | while read name class addr size; do
	case $name in
		_fini)
			continue
			;;
		_init)
			continue
			;;
		_edata)
			continue
			;;
	esac
	case $class in
		[TV])
			if [ "$SECT" != ".text" ]; then
				echo .text
				SECT=".text"
			fi
			echo .global $name
			echo $name:
			;;
		D)
			if [ "$size" = "" ]; then
				continue
			fi
			if [ "$SECT" != ".data" ]; then
				echo .data
				SECT=".data"
			fi
			echo .global $name
			echo $name:
			echo .size $name, 0x${size}
			;;
		[BS])
			if [ "$size" = "" ]; then
				continue
			fi
			if [ "$SECT" != ".bss" ]; then
				echo .bss
				SECT=".bss"
			fi
			echo .global $name
			echo $name:
			echo ".size $name, 0x${size}"
			;;
		R)
			if [ "$size" = "" ]; then
				continue
			fi
			if [ "$SECT" != ".rodata" ]; then
				echo .section .rodata
				SECT=".rodata"
			fi
			echo .global $name
			echo $name:
			echo ".size $name, 0x${size}"
			;;
		[UWAabcdefghijklmnopqrstuvwxyz])
			continue
			;;
		*)
			echo Unknown class $class for $name 1>&2
			exit 1

	esac
done
}

lib=release/$CROSS/$CROSS/sysroot/usr/lib
for n in lib/*.nm; do
	bn=$(basename $n .nm)
	gen $n | ${CROSS}-gcc -shared -Wl,-soname,$bn -s -x assembler - -o $lib/$bn
	noso=${bn%.so.*}
	if [ "$noso" != "$bn" ]; then
		ln -s $bn $lib/${noso}.so
		echo ln -s $bn $lib/${noso}.so
	fi
done

