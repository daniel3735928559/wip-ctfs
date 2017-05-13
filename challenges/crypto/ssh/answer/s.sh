#!/usr/bin/bash
# Usage: ./s.sh <pcap> <core> <ssh> <src_ip> <dst_ip>
[[ ! -x data ]] && mkdir data
tshark -n -r "$1" -T fields -e ip.src -e ip.dst -e ssh.packet_length_encrypted -e ssh.encrypted_packet|grep -v '^\s*$'|grep :|awk '{print $1","$2","$3","$4}' > data/traffic
gdb "$3" "$2" <src/ssh_gdb
gdb "$3" "$2" <src/ssh_gdb |grep = | sed 's/.*{//;s/}//;s/ //g' > data/keys
cd src
python ssh_dec.py ../data/traffic ../data/keys "$4" "$5"
cd ..
rm -rf data
