import sys

with open(sys.argv[1],"rb") as f:
    s = f.read()
while len(s)%4 != 0: s += bytes([0x90])
ss = [int.from_bytes(s[i:i+4],'little') for i in range(0,len(s),4)]
k = int(sys.argv[2],16)
u32s = [ss[i]^k for i in range(len(ss))]
ans = bytes()
for x in u32s:
    ans += bytes(x.to_bytes(4,'little'))
sys.stdout.buffer.write(ans)
