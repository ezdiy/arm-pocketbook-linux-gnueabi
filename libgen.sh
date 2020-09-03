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
		[DBG])
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

