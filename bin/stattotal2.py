#!/usr/bin/env python
import os
import sys
import copy
from threading import Thread

sys.path.append(os.path.join(os.path.dirname(__file__),'..','lib'))
from zone2db import SQLHelper
tmp = []
vals = {'date':"",'recs':"",'domains':"",'del':"",'new':""}
def doit():
	sql = SQLHelper("")
	folder = "../archives/stat/total"
	if not os.path.exists(folder):
		os.makedirs(folder)
	times = sql.getCreateTimes()
	#print(str(times))
	
	toproc = [[],[],[],[],[],[],[],[],[],[]]
	i = 0
	threads = []
	for x in range(0, len(times)):
		if i == len(toproc):
			i = 0
		toproc[i].append(times[x])
	for x in toproc:
		print("start new thread")
		t = Thread(target=dothread, args=(x,))
		t.start()
		threads.append(t)
	for x in threads:
		x.join()
			
		
	with open(folder + "/sum.csv","w") as f:
		f.write("date;recs;domains;del;new\n")
		for x in tmp:
			f.write(x['date'] + ";" + x['recs'] + ";" + x['domains'] + ";" + x['del'] + ";" + x['new'] + "\n")
					
	
	
def dothread(todo):
	sql = SQLHelper("")
	for x in todo:
		recs = str(sql.recsAtTs(str(x[0]))[0][0])
		doms = str(sql.domainsAtTs(str(x[0]))[0][0])
		old = str(sql.recsdelAtTs(str(x[0]))[0][0])
		new = str(sql.recsnewAtTs(str(x[0]))[0][0])
		print(recs + "\t" + doms + "\t" + old + "\t" + new)
		val = copy.deepcopy(vals)
		val['date'] = str(x[0])[8:10] + "." + str(x[0])[5:7] + "." + str(x[0])[:4]	
		val['recs'] = recs
		val['domains'] = doms
		val['del'] = old
		val['new'] = new
		tmp.append(val)


