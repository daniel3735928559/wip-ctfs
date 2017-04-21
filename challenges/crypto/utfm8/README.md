# UTF M8?

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

The list is simply the raw bytes of a UTF-8 encoded string.  If you
decode it as such and print the string, it will be the flag, printed
upside down.  `answer.py` contains a tool to do this

```
python answer.py
```

will print the flag, upside down.  Brain power, or else Python 2's
`upsidedown` module can be used to overcome this.
