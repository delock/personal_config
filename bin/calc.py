#!/usr/bin/python3

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
#args = re.sub("([0-9\)\s])x([0-9\)\s])", "\g<1>*\g<2>", args)
#args = re.sub("([0-9\)\s])p([0-9\(\s])", "\g<1>+\g<2>", args)
#args = re.sub("([0-9\)\s])\^([0-9\(\s])", "\g<1>**\g<2>", args)
args = re.sub("([0-9]+)!", "factorial(\g<1>)", args)
args = re.sub("([0-9]+)!", "factorial(\g<1>)", args)
try:
    res = eval(args)
    if res > 1024*1024*1024 :
        human_readable = "[" + str(int(res*100/(1024*1024*1024)+0.5)/100) + "G]"
    elif res > 1024*1024 :
        human_readable = "[" + str(int(res*100/(1024*1024)+0.5)/100) + "M]"
    elif res > 1024 :
        human_readable = "[" + str(int(res*100/1024+0.5)/100) + "K]"
    else :
        human_readable = ""
    if type(res) == int :
        if (0<=res<=9):
            print (res)
        else:
            if(res>=0):
                print ("%s = %d(0x%x) %s"%(args, res, res, human_readable))
            else:
                print ("%s = %d(0x%x)"%(args, res, (1<<32)+res))
    else:
        print (str(res) + human_readable)
except:
    print ("cannot evaluate %s"%args)

