import base64, socketserver, subprocess, sys, hashlib, random, zlib
from threading import Thread
from Crypto import Random
from Crypto.Cipher import AES
import Crypto.Util.Counter

ctr = Crypto.Util.Counter.new(16*8)
secrets = ["sample secret message"]

try:
    with open("secrets","r") as f:
        secrets = f.read().split("\n")
    secrets = [s for s in secrets if len(s) > 10]
    print(secrets)
except:
    print("File: secrets is not readable, using default secret")

def encrypt(raw, key):
    key = hashlib.sha256(key.encode()).digest()
    cipher = AES.new(key, AES.MODE_CTR, counter=ctr)
    return base64.b64encode(cipher.encrypt(raw))

def decrypt(enc, key):
    enc = base64.b64decode(enc)
    cipher = AES.new(key, AES.MODE_CTR, counter=ctr)
    return cipher.decrypt(enc).decode('utf-8')

def send(secret_msg, user_msg):
    msg = zlib.compress(bytes(secret_msg + "|" + user_msg, 'ascii'))
    return encrypt(msg, "weiaecnkahbcksckauwyeckayewcsudlc")    

class MessageHandler(socketserver.BaseRequestHandler):
    def handle(self):
        data = self.request.recv(1024)
        text = data.decode('utf-8')
        secret = random.choice(secrets)
        s = send(secret,text)
        self.request.send(s)
        self.request.close()

class LevelServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    daemon_threads = True
    allow_reuse_address = True

    def __init__(self, server_address, RequestHandlerClass):
        socketserver.TCPServer.__init__(self, server_address, RequestHandlerClass)

server = LevelServer(('0.0.0.0', int(sys.argv[1])), MessageHandler)

try:
    server.serve_forever()
except KeyboardInterrupt:
    sys.exit(0)
