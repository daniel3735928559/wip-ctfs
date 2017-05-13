# "Conscience do cost"

## Level categories

Crypto, networking

## Flavourtext

You and Alice are both sending encrypted messages to Bob.  Bob is
remote, and with poor internet, so your team needs to be as efficient
as possible.  In your setup, Alice has the uplink and you send to her
your messages for Bob.  She will tack each of your messages onto one
of hers (or a randomly chosen old message, for redundancy's sake),
encode the result according to her scheme, and send that to Bob.  She
will also send the ciphertext to you for logging purposes.

You notice that this setup enables Alice to read your messages to Bob,
but forbids you from seeing hers.  She is planning to meet Bob.  Can
you work out where?

## Hint

Sometimes, CRIME does pay

## To run

Place your desired secret or secrets in the `secrets` file.  More than
one is significantly harder than one.  Having two of very similar
lengths is harder still.  Having anything other than English text is
harder still.  Then run:

```
python level.py 2000
```

## To play:

```
nc $server_ip 2000
```

Type in a message, and you'll get the encrypted stuff back.  

## Solution

The file `answer.py` contains a tool that can be used to find the
answer, along with the `words` file.

The basic idea is that it will try sending separately each of the
10000 most common English words as a message and will observe which of these results in 

```
$ python answer.py localhost 2000 ''|sort -n -r -k 2 | tail
annotation 0.9137931034482759
adaptation 0.9137931034482759
citations 0.9122807017543859
rotation 0.9107142857142857
citation 0.9107142857142857
avenue 0.9074074074074074
stationery 0.896551724137931
stations 0.8928571428571429
station 0.8909090909090909
baltimore 0.8771929824561403
```

So it looks like "baltimore" and "station" are part of the text.  Let
us place these in our message and try adding other words and see what
we get:


```
$ python answer.py localhost 2000 ' baltimore station'|sort -n -r -k 2 | tail
patio 0.8059701492537313
nation 0.8059701492537313
latin 0.8059701492537313
haven 0.8059701492537313
rotation 0.7971014492753623
citation 0.7971014492753623
venue 0.7910447761194029
rogers 0.7910447761194029
avenue 0.7910447761194029
stations 0.782608695652174
```

This makes it look like "rogers" and "avenue" are also relevant.  It
turns out, there is a Rogers Avenue metro station in Baltimore, so
that looks like the place.

