import sys

k1 = sys.argv[1]
k1 = [int(k1[i:i+2],16) for i in range(0,len(k1),2)]
k2 = sys.argv[2]
k2 = [int(k2[i:i+2],16) for i in range(0,len(k2),2)]
if len(k1) == len(k2):
    print("".join([hex(k1[i]^k2[i])[2:] for i in range(len(k1))]))
