x=exploitable
nasm -f elf$1 "$x".s -o "$x".o && ld "$x".o -o bin/"$x"
rm "$x".o
