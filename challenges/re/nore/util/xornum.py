import sys

print hex(int(sys.argv[1],16)^int(sys.argv[2],16))[2:]
