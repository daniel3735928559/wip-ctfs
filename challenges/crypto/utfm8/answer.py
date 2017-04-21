with open("puzzle","r") as f:
    l = [int(x) for x in f.read().split(", ")]
with open("ans","wb") as f:
    f.write(bytearray(l))
