import sys

with open(sys.argv[1],"rb") as f:
    s = [ord(x) for x in f.read()]
    k = int(sys.argv[2],16)
    sys.stdout.write(bytearray([s[i]^k for i in range(len(s))]))
