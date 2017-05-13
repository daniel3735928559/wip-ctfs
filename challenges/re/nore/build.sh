#!/bin/bash
#nasm -f elf -o sc.o sc.s && ld -N -o sc sc.o
nasm -f elf -o stage1.o stage1.s && ld -N -o stage1 stage1.o
k1=$(./stage1 |hexdump -e '4/4 "%08x"')
k2=$(cat .flag | cut -c 1 | tr -d '\n' | hexdump -e '1/1 "%02x"')
echo $k1
echo $k2
#nasm -f elf -o stage2.o stage2.s && ld -N -o stage2 stage2.o
[[ ! -x temp ]] && mkdir temp;
cat stage2.s|sed '/TEST/d' > temp/stage2.s
cat stage1.s|sed '/TEST/d' > temp/stage1.s
cat sc.s | sed '/TEST/d' > temp/sc.s
cd temp
for x in $(seq 3 4 15); do 
	y=$(cat ../.flag| cut -c $x-$((x+3)) | tr -d '\n'| hexdump -e '1/4 "%02x"' -e '"\n"');
	z=$(python ../util/xornum.py $y 02eb5a5b|tr -d '\n');
	sed -i "s/VAR$x/$z/" stage2.s;
done
nasm -f bin stage2.s -o stage2.raw
nasm -f bin stage1.s -o stage1.raw
python3 ../util/xorenc4.py stage2.raw $k1 > stage2.enc
python ../util/xorenc.py stage1.raw $k2 > stage1.enc
sed -i "s/LEN1/$(wc -c stage1.enc | sed 's/ .*//')/" sc.s
sed -i "s/LEN2/$(wc -c stage2.enc | sed 's/ .*//')/" sc.s
nasm -f elf -o sc.o sc.s && ld -N -o ../sc sc.o
cd ..
rm *.o
strip sc
