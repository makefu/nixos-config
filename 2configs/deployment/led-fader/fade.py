#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p python3 python35Packages.docopt
""" usage: run [options] NUMLEDS (loop [--skip-unchanged] [STEP] [DELAY]|single STARTVAL)

    --add-empty       essentially add a single empty led in front, does not count into NUMLEDS

    --mode=TYPE         mode of fading (Default: chain)
    --output=TYPE       output type, either json or raw (Default: json)
    --skip-unchanged    if the value in the loop is unchanged, skip the output

running with loop this script essentially becomes a generator which outputs the
next value each "DELAY"
single returns a single output with STARTVAL as starting point for the first led

NUMLEDS is the number of leds to output data for (--add-empty does not count in here)
STEP defaults to 0.01
DELAY defaults to 1 second

"""
from docopt import docopt
import time
from colorsys import hsv_to_rgb
import json
import sys

def calc_chain(numleds,val):
    divisor = 1.0 /  numleds
    ret = []
    for i in range(numleds):
        v = float(divisor * i + val) % 1
        r,g,b = hsv_to_rgb(v,0.9,1)
        ret.append([int(r*255),
                    int(g*255),
                    int(b*255)])
    return ret

def calc_single(numleds,val):
    ret = []
    for i in range(numleds):
        r,g,b = hsv_to_rgb(val,1,1)
        ret.append([int(r*255),
                    int(g*255),
                    int(b*255)])
    return ret

def main():
    args = docopt(__doc__)
    numleds = int(args['NUMLEDS'])
    mode = args['--mode']
    step = float(args['STEP'] or 0.01)
    delay = float(args['DELAY'] or 1)
    val = float(args['STARTVAL'] or 0)
    last = []
    while True:
        if mode == "chain":
            ret = calc_chain(numleds,val)
        elif mode == "single":
            ret = calc_single(numleds,val)

        if args['--add-empty']:
            ret.insert(0,[0,0,0])

        # early serialization makes comparsion easy
        ret = json.dumps(ret)
        if not (args['--skip-unchanged'] and last == ret):
            last = ret
            print(ret)
            sys.stdout.flush()
        if args['single']:
            break
        else:
            val += step % 1
            time.sleep(delay)



if __name__ == "__main__":
    main()
