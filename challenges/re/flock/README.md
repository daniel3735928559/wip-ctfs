# "Fork is the bomb"

## Level categories

Exploitation, reverse engineering

## Hint

Think about canaries

## To run

Use a 64-bit machine.  Place a bunch (say, 64 bytes each) of random
data into .canary, .password, and place the flag into .flag.  Then
run:

```
./build.64.sh srv
./run.sh 3000
```

## To play:

```
nc localhost 3000
```

Try to guess the correct password.  If you get it right, you will get
the flag back.

## Solution

The file `answer.py` contains a tool that can be used to find the
answer:

```
$ python answer.py localhost 5555
enter your password:
flag{liuewakdsc}
```

