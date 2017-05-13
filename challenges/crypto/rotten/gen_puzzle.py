with open(".flag","r") as f: msg = "jk "+f.read().replace("\n","")+"\rNOTHING TO SEE HERE  \x1b[A\r"+"lo"*40+"\n\r"
def rotl(x,s,w):
    return (x << s)%(1<<w) + (x >> w-s)

print(", ".join([str(rotl(ord(c),3,8)) for c in msg]))
