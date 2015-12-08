#!/usr/bin/env python3

# Usage:
# _from=krebs statedir=. python sed-plugin.py 'dick butt'
# _from=krebs statedir=. python sed-plugin.py 's/t/l/g'
## dick bull
import shelve
from os import environ
from os.path import join
from sys import argv
d = shelve.open(join(environ['statedir'],'sed-plugin.shelve'),writeback=True)
import re

def is_regex(line):
    # TODO: match s/di\/ck/butt/ but not s/di/ck/butt/
    myre = re.compile(r'^s/((?:\\/|[^/])+)/((?:\\/|[^/])*)/([ig]*)$')
    return myre.match(line)

line = argv[1]
m = is_regex(line)

if m:
    f,t,flagstr = m.groups()
    fn = f.replace('\/','/')
    tn = t.replace('\/','/')
    flags =  0
    count = 1
    if flagstr:
        if 'i' in flagstr:
            flags = re.IGNORECASE
        if 'g' in flagstr:
            count = 0
    else:
        flagstr = ''
    last = d.get(environ['_from'],None)
    if last:
        print(fn,tn,last)
        #print(re.sub(fn,tn,last,count=count,flags=flags))
        from subprocess import Popen,PIPE
        p = Popen(['sed','s/{}/{}/{}'.format(f,t,flagstr)],stdin=PIPE,stdout=PIPE )
        so,_ = p.communicate(last+"\n")
        if p.returncode:
            print("something went wrong when trying to process your regex")
        print(so)


    else:
        print("no last message")
else:
    print("setting line")
    d[environ['_from']] = line

d.close()
