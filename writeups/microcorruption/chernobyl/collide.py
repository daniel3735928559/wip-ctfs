import itertools

hashtable = {i:[] for i in range(0x10000)}
letters = map(chr, range(ord('a'),ord('z')+1))

def hashfn(s):
    return sum([31**(i+1) * c for i,c in enumerate(map(ord,s[::-1]))])%0x10000

# hash all 4-letter names
for name in ["".join(x) for x in itertools.product(letters, repeat=4)]:
    hashtable[hashfn(name)].append(name)
    
# find the most common hash
most_common_hash = max(range(0x10000),key=lambda name:len(hashtable[name]))

# show all usernames with that hash
print(";".join(["new {} 1".format(x) for x in hashtable[most_common_hash]]))
