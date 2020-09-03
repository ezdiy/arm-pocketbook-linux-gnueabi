#!/bin/bash
CROSS=arm-pocketbook-linux-gnueabi
function gen() {
SECT=""
cat $1 | while read name class _; do
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
		T)
			if [ "$SECT" != ".text" ]; then
				echo .text
				SECT=".text"
			fi
			echo .global $name
			echo $name:
			;;
		D)
			if [ "$SECT" != ".data" ]; then
				echo .data
				SECT=".data"
			fi
			echo .global $name
			echo $name:
			;;
	esac
done
}

for n in lib/*.nm; do
	bn=$(basename $n .nm)
	gen $n | ${CROSS}-gcc -shared -s -x assembler - -o release/$CROSS/$CROSS/sysroot/usr/lib/$bn
done

