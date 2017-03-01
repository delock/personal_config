#!/usr/bin/python2

# add these lines to your ~/.bashrc
#=() {
#    python ~/bin/calc.py $@
#}


import sys
from math import *
import re
args = ''.join(sys.argv[1:])
#print args
args = re.sub("\[", "(", args)
args = re.sub("\]", ")", args)
args = re.sub("([0-9\)\s])x([0-9\)\s])", "\g<1>*\g<2>", args)
args = re.sub("([0-9\)\s])p([0-9\(\s])", "\g<1>+\g<2>", args)
args = re.sub("([0-9\)\s])\^([0-9\(\s])", "\g<1>**\g<2>", args)
args = re.sub("([0-9]+)!", "factorial(\g<1>)", args)
args = re.sub("([0-9]+)!", "factorial(\g<1>)", args)
try:
    res = eval(args)
    if type(res) == int :
        if (0<=res<=9):
            print res
        else:
            if(res>=0):
                print "%s = %d(0x%x)"%(args, res,res)
            else:
                print "%s = %d(0x%x)"%(args, res, (1<<32)+res)
    else:
        print res
except:
    print "cannot evaluate %s"%args

