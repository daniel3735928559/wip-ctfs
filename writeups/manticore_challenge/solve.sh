gcc -o manticore_challenge manticore_challenge.c
objdump -d -Mintel manticore_challenge |grep 'call.*exit' | sed 's/:.*//;s/  /0x/' > exit_addrs
python2 ans.py manticore_challenge
rm -rf mcore_* exit_addrs manticore_challenge
