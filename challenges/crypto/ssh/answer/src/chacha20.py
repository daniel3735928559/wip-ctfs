# Pure Python ChaCha20
# Based on Numpy implementation: https://gist.github.com/chiiph/6855750
# Based on http://cr.yp.to/chacha.html
#
# I wanted an implementation of ChaCha in clean, understandable Python
# as a way to get a handle on the algorithm for porting to another language.
# There are plenty of bindings but few pure implementations, because
# Pure Python is too slow for normal practical use in Cryptography.
#
# The preceding implementation used NumPy, which avoided a lot of the
# specific issues of integer management in Python and hid a lot of the
# necessary functionality under convenience methods. The below is a rewrite
# using only pure python functions and types.
# 
# I have not done anything, use-wise, beyond making the tests pass; this
# could still do with improvement, tidying and perhaps (while we're using
# python anyway) conversion into an object.

import binascii

def isuint32(i):
    return isinstance(i, int) and abs(i) == i and i < 0xFFFFFFFF

def asint32(i):
    return i & 0xFFFFFFFF

def fromstring(bytestring, byte_length):
    assert len(bytestring) % (byte_length) == 0
    for i in range(0, len(bytestring), byte_length):
        c = bytestring[i: i+byte_length]
        yield int.from_bytes(c, 'little')

def salsa20_wordtobyte(inp):
    x = inp.copy()
    def quarter_round(a, b, c, d):
        rotate = lambda v, c: asint32((asint32(v << c)) | (asint32(v >> (32 - c))))
        x[a] = asint32(x[a] + x[b])
        x[d] = asint32(rotate(x[d] ^ x[a], 16))
        x[c] = asint32(x[c] + x[d])
        x[b] = asint32(rotate(x[b] ^ x[c], 12))
        x[a] = asint32(x[a] + x[b])
        x[d] = asint32(rotate(x[d] ^ x[a], 8))
        x[c] = asint32(x[c] + x[d])
        x[b] = asint32(rotate(x[b] ^ x[c], 7))
    for i in range(10):
        quarter_round(0, 4,  8, 12)
        quarter_round(1, 5,  9, 13)
        quarter_round(2, 6, 10, 14)
        quarter_round(3, 7, 11, 15)
        quarter_round(0, 5, 10, 15)
        quarter_round(1, 6, 11, 12)
        quarter_round(2, 7,  8, 13)
        quarter_round(3, 4,  9, 14)
    for i in range(16):
        x[i] = asint32(x[i] + inp[i])
    x = [i for n in x for i in n.to_bytes(4, 'little')]
    return x

sigma = b"expand 32-byte k"

def keysetup(iv, key, position = 0):
    assert isuint32(position)
    key_arr =   list(fromstring(key,   4))
    iv_arr =    list(fromstring(iv,    4))
    const_arr = list(fromstring(sigma, 4))

    ctx = [0] * 16

    ctx[4] = key_arr[0]
    ctx[5] = key_arr[1]
    ctx[6] = key_arr[2]
    ctx[7] = key_arr[3]
    ctx[8] = key_arr[4]
    ctx[9] = key_arr[5]
    ctx[10] = key_arr[6]
    ctx[11] = key_arr[7]

    ctx[0] = const_arr[0]
    ctx[1] = const_arr[1]
    ctx[2] = const_arr[2]
    ctx[3] = const_arr[3]

    ctx[12] = position
    ctx[13] = position

    ctx[14] = iv_arr[0]
    ctx[15] = iv_arr[1]

    return ctx

def encrypt_bytes(ctx, m, byts):
    c = [0] * len(m)

    if byts == 0:
        return

    c_pos = 0
    m_pos = 0

    while True:
        output = salsa20_wordtobyte(ctx)
        ctx[12] = asint32(ctx[12] + 1)

        if ctx[12] == 0:
            ctx[13] = asint32(ctx[13] + 1)

        if byts <= 64:
            for i in range(byts):
                c[i + c_pos] = asint32(m[i + m_pos] ^ output[i])
            return c

        for i in range(64):
            c[i + c_pos] = asint32(m[i + m_pos] ^ output[i])

        byts  = asint32(byts  - 64)
        c_pos = asint32(c_pos + 64)
        m_pos = asint32(m_pos + 64)

def decrypt_bytes(ctx, c, byts):
    return encrypt_bytes(ctx, c, byts)

def to_string(c):
    c_str = ""
    for i in c:
        c_str += chr(i)
    return c_str

test_vectors_key = [
    b"00000000000000000000000000000000000000000000000000000000"
    b"00000000",
    b"00000000000000000000000000000000000000000000000000000000"
    b"00000001",
    b"00000000000000000000000000000000000000000000000000000000"
    b"00000000",
    b"00000000000000000000000000000000000000000000000000000000"
    b"00000000",
    b"000102030405060708090a0b0c0d0e0f101112131415161718191a1b"
    b"1c1d1e1f"
]

test_vectors_iv = [
    b"0000000000000000",
    b"0000000000000000",
    b"0000000000000001",
    b"0100000000000000",
    b"0001020304050607"
]

test_vectors_c_expected = [
    b"76b8e0ada0f13d90405d6ae55386bd28bdd219b8a08ded1aa836efcc"
    b"8b770dc7da41597c5157488d7724e03fb8d84a376a43b8f41518a11c"
    b"c387b669",
    b"4540f05a9f1fb296d7736e7b208e3c96eb4fe1834688d2604f450952"
    b"ed432d41bbe2a0b6ea7566d2a5d1e7e20d42af2c53d792b1c43fea81"
    b"7e9ad275",
    b"de9cba7bf3d69ef5e786dc63973f653a0b49e015adbff7134fcb7df1"
    b"37821031e85a050278a7084527214f73efc7fa5b5277062eb7a0433e"
    b"445f41e3",
    b"ef3fdfd6c61578fbf5cf35bd3dd33b8009631634d21e42ac33960bd1"
    b"38e50d32111e4caf237ee53ca8ad6426194a88545ddc497a0b466e7d"
    b"6bbdb004",
    b"f798a189f195e66982105ffb640bb7757f579da31602fc93ec01ac56"
    b"f85ac3c134a4547b733b46413042c9440049176905d3be59ea1c53f1"
    b"5916155c2be8241a38008b9a26bc35941e2444177c8ade6689de9526"
    b"4986d95889fb60e84629c9bd9a5acb1cc118be563eb9b3a4a472f82e"
    b"09a7e778492b562ef7130e88dfe031c79db9d4f7c7a899151b9a4750"
    b"32b63fc385245fe054e3dd5a97a5f576fe064025d3ce042c566ab2c5"
    b"07b138db853e3d6959660996546cc9c4a6eafdc777c040d70eaf46f7"
    b"6dad3979e5c5360c3317166a1c894c94a371876a94df7628fe4eaaf2"
    b"ccb27d5aaae0ad7ad0f9d4b6ad3b54098746d4524d38407a6deb"
]

def test_passes(i):
    key = binascii.unhexlify(test_vectors_key[i])
    iv = binascii.unhexlify(test_vectors_iv[i])
    c_expected = test_vectors_c_expected[i]

    m = [0] * (len(c_expected) // 2)

    ctx = keysetup(iv, key)
    c = encrypt_bytes(ctx, m, len(m))
    c_str = binascii.hexlify(b''.join([int(x).to_bytes(1,'little') for x in c]))
    print("\tc_str:\t\t{}\n\tc_expected:\t{}".format(c_str, c_expected))
    return c_str == c_expected

def run_tests():
    amount_tests = len(test_vectors_c_expected)

    for i in range(amount_tests):
        print("{0}. TEST RESULT: {1}".format(i, test_passes(i)))

if __name__ == "__main__":
    run_tests()
