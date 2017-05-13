import sys, socket, base64

random = "qwertyuiopasdfghjklzxcvbnmijiyrfszwqerukmijhuteszq"

with open("words","r") as f:
    l = f.read().split("\n")

host = sys.argv[1]
port = int(sys.argv[2])
ans = sys.argv[3] if len(sys.argv) > 3 else ""

for w in l:
    if len(w) == 0:
        break;
    if ' '+w in ans:
        continue
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((host, port))
    msg = w + ans
    s.send(msg.encode('ascii'))
    s1 = base64.b64decode(s.recv(1024).decode())

    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((host, port))
    s.send(random[:len(msg)].encode('ascii'))
    s2 = base64.b64decode(s.recv(1024).decode())
    print(w,float(len(s1))/float(len(s2)))
