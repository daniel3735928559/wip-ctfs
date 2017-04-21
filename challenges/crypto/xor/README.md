# XOR

## Level categories

Crypto

## To generate

Place flag in `.flag` and run: 

```
python gen_puzzle.py 151 > puzzle
```

## To deploy

Give contestants the `puzzle` file and any hints you want

## Solution

The file `answer.py` contains a tool that can be used to xor the
contents of `puzzle` with any number.  For example,

```
python answer.py 151
```

will print the flag.
