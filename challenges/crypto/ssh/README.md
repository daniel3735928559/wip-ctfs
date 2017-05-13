# SSH

## Level categories

Crypto

## Flavourtext

Your agent has exfiltrated some data from his mission on the inside.
Your target is Niko, and all you need is access to his machine.
However, his password is very strong.

## To deploy

Provide the `recipes.tar.gz` file and any hints you want

## Solution

```
cd answer
./s.sh ../recipes/ssh.pcap ../recipes/core.3936 ../recipes/ssh 10.100.100.25 10.100.100.38
```
