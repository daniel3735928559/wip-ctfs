gcc -o bin/su0 su0.c
gcc -o bin/su1 su1.c
gcc -zexecstack -o bin/su2 su2.c
gcc -o bin/su2.1 su2.c
gcc -zexecstack -o bin/su3 su3.c
gcc -o bin/su4 -m32 -fno-stack-protector -zexecstack su4.c
gcc -o bin/ls -m32 -fno-stack-protector -fpie ls.c
