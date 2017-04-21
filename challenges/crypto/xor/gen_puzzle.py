import sys

with open(".flag","r") as f: 
    msg = f.read().replace("\n","")
def xor(x,k):
    return x^k

print(", ".join([str(xor(ord(c),int(sys.argv[1]))) for c in msg]))
