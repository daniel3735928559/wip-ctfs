import sys, binascii, chacha20

def dec_bytes(s):
    return binascii.unhexlify(bytes(s.replace(":",""),"ascii"))

def swap_ends(x):
    return int.from_bytes(x.to_bytes(4,'little'),'big')
    
def u32_add(x,a):
    return swap_ends(swap_ends(x)+a)

# read files

# read encrypted session
with open(sys.argv[1],"r") as f:
    s = f.read()
data = [x.split(",") for x in s.split("\n") if len(x) > 0]
data = [{"src":x[0],"dst":x[1],"el":dec_bytes(x[2]),"ed":dec_bytes(x[3])} for x in data]

# read keys
with open(sys.argv[2],"r") as f:
    s = f.read()
print(s)
txh,txd,rxh,rxd = [[int(x) for x in l.split(",") if len(x) > 0] for l in s.split("\n") if len(l) > 0]

print("KEYS",txd,txh,rxd,rxh)

txiv = 0
rxiv = 0

ctx_send = bytes()
ctx_send_len = bytes()
ctx_recv = bytes()
ctx_recv_len = bytes()
src_ip = sys.argv[3]
dst_ip = sys.argv[4]
for x in [x.to_bytes(4, 'little') for x in txd]: ctx_send += x
for x in [x.to_bytes(4, 'little') for x in txh]: ctx_send_len += x
for x in [x.to_bytes(4, 'little') for x in rxd]: ctx_recv += x
for x in [x.to_bytes(4, 'little') for x in rxh]: ctx_recv_len += x
txiv = swap_ends(3)
rxiv = swap_ends(3)
for x in data:
    if x['src'] == src_ip:
        txd[12] = 1
        txh[12] = 0
        dli = 0xffffffff
        rxiv = swap_ends(0)
        j = 0
        while(dli > 0xffff and j < 1000):
            txh[15] = txiv
            txd[15] = txiv
            dl = chacha20.decrypt_bytes(txh,x['el'],4)
            dli = int.from_bytes(dl,'big')
            txiv = u32_add(txiv,1)
            j += 1
        txd[15] = swap_ends(5)#u32_add(txiv,1)
        dd = bytes(chacha20.decrypt_bytes(txd,x['ed'],len(x['ed'])))
        print("TX",txh,txiv)
        print(dl)
        print(dd)
    else:
        rxd[12] = 1
        rxh[12] = 0
        rxh[15] = rxiv
        rxd[15] = rxiv
        print("RX",rxh)
        dl = chacha20.decrypt_bytes(rxh,x['el'],4)
        dli = int.from_bytes(dl,'big')
        dd = bytes(chacha20.decrypt_bytes(rxd,x['ed'],len(x['ed'])))
        if dl[0] == 0:
            rxiv = u32_add(rxiv,1)
        print(dl)
        print(dd)
    print('--------------------')

print(u32_add(67108864,4))
