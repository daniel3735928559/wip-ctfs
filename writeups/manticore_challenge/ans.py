import sys
from manticore import Manticore

m = Manticore(sys.argv[1])
print("Starting")
data = 0
entry = 0x4008ec
pre_puts = 0x4008f5
post_gets = 0x400912
pre_check = 0x400916
post_check = 0x40091e
with open("exit_addrs") as f:
    exits = [int(x,16) for x in f.read().split("\n") if len(x) > 0]
    #[0x4005e5,0x400618,0x40064a,0x40067a,0x4006ac,0x4006e2,0x400712,0x400742,0x400775,0x4007ab,0x4007e1]

@m.hook(pre_puts)
def hook(state):
    print("skipping puts/gets")
    state.cpu.EIP = post_gets

@m.hook(pre_check)
def hook(state):
    global data
    print("setting up input")
    buf = state.new_symbolic_buffer(12)
    data = state.cpu.RBP-0x10
    print(data)
    state.cpu.write_bytes(data, buf)

@m.hook(post_check)
def hook(state):
    global data
    print("solving")
    buf = state.cpu.read_bytes(data, 12)
    res = ''.join(chr(state.solve_one(x)) for x in buf)
    print("RESULT:")
    print(res)
    m.terminate()

def get_addresses(m):
    for x in exits:
        @m.hook(x)
        def exit_hook(state):
            print("abandoning")
            state.abandon()
    
get_addresses(m)
print("hooked")
m.run()
