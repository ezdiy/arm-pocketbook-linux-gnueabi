#!/bin/bash
for n in *.so*; do
	if [ ! -e $n ]; then
		continue
	fi
	if [[ $n = *.nm ]]; then
		continue
	fi
	soname=$(objdump -p $n | grep SONAME | awk {'print $2'})
	nm -f p -D $n > $soname.nm
done
