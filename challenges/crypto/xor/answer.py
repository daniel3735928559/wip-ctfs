import sys

with open("puzzle","r") as f: 
    l = [int(x) for x in f.read().split(", ")]
def xor(x,k):
    return x^k

print("".join([chr(xor(c,int(sys.argv[1]))) for c in l]))
