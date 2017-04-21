import upsidedown
with open(".flag") as f: 
   print(", ".join([str(x) for x in list(bytearray(upsidedown.transform("i'm dizzy "+f.read()).encode('utf-8')))]))
