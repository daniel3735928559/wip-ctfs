with open("puzzle","r") as f: 
    msg = f.read()

l = [int(x) for x in msg.split(", ")]

def rotr(x,s,w):
    return (x << (w-s))%(1<<w) + (x >> s)

print("".join([chr(rotr(c,3,8)) for c in l]))
