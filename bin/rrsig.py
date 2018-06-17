#!/usr/bin/env python
"""
Stichprobe RRSIG:
zztop.se.
vvsinsats.se.
tibiaforum.se.
offlinepizza.se.
lyckasleta.se.
moraak.se.
mookapan.se.
jefo.se.
ibuprofen.se.
"""
import os
import sys
sys.path.append(os.path.join(os.path.dirname(__file__),'..','lib'))
from zone2db import SQLHelper


doms = [
"zztop.se.",
"vvsinsats.se.",
"tibiaforum.se.",
"offlinepizza.se.",
"lyckasleta.se.",
"moraak.se.",
"mookapan.se.",
"jefo.se.",
"ibuprofen.se."
]

def doit():
	sql = SQLHelper("")
	folder = "../archives/stat/total/rrsig"
	if not os.path.exists(folder):
		os.makedirs(folder)
	for x in doms:
		result = sql.getrrsig(x)
		with open(folder + "/"+x+"csv","w") as f:
			f.write("name;ttl;value;created;deleted\n")
			for y in result:
				f.write(str(y[0])+","+str(y[1])+","+str(y[2])+","+str(y[3])+","+str(y[4])+"\n")
	
	
	
	
	
	
	
	
	
	
