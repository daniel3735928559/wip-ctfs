# ROTten

## Level categories

Crypto

## To generate

Place flag in `.flag` and run: 

```
python gen_puzzle.py > puzzle
```

## To deploy

Give contestants the `puzzle` file and any hints you want

## Solution

Each number is a byte that has been left-rotated by 3 bits.  The idea
is to right-rotate them back.  The file `answer.py` contains a tool
that can do this.  For example,

```
python answer.py
```

will print the flag.  Almost.  Except if you do this in a terminal,
terminal escape codes will cause the flag to be overwritten.

```
python answer.py | less
```

will ovecome this, for example.