#!/usr/bin/env python
import os
import sys
import copy

sys.path.append(os.path.join(os.path.dirname(__file__),'..','lib'))
from zone2db import SQLHelper

def doit():
	sql = SQLHelper("")
	folder = "../archives/stat/total"
	if not os.path.exists(folder):
		os.makedirs(folder)
	times = sql.getCreateTimes()
	#print(str(times))
	vals = {'date':"",'a':0,'aaaa':0,'dnskey':0,'ds':0,'ns':0,'nsec':0,'rp':0,'rrsig':0,'soa':0,'srv':0,'txt':0}
	tmp = {'new':[], 'del':[]}
		
	for x in range(0, len(times)):
		old = sql.recdelAtTs(str(times[x][0]))
		print(str(old))
		new = sql.recnewAtTs(str(times[x][0]))
		print(str(new))
		vals['date'] = str(times[x][0])[8:10] + "." + str(times[x][0])[5:7] + "." + str(times[x][0])[:4]
		tmp['del'].append(copy.deepcopy(vals))
		tmp['new'].append(copy.deepcopy(vals))
		for y in new:
			tmp['new'][x][y[0]] = y[1]
		for y in old:
			tmp['del'][x][y[0]] = y[1]
	with open(folder + "/new.csv","w") as f:
		f.write("date;a;aaaa;dnskey;ds;ns;nsec;rp;rrsig;soa;srv;txt\n")
		for x in tmp['new']:
			line = str(x['date']) + ";" + str(x['a']) + ";" + str(x['aaaa']) + ";" + str(x['dnskey']) + ";" + str(x['ds']) + ";" + str(x['ns']) + ";" + str(x['nsec']) + ";" + str(x['rp']) + ";" + str(x['rrsig']) + ";" + str(x['soa']) + ";" + str(x['srv']) + ";" + str(x['txt']) + "\n"
			f.write(line)
	with open(folder + "/del.csv","w") as f:
		f.write("date;a;aaaa;dnskey;ds;ns;nsec;rp;rrsig;soa;srv;txt\n")
		for x in tmp['del']:
			line = str(x['date']) + ";" + str(x['a']) + ";" + str(x['aaaa']) + ";" + str(x['dnskey']) + ";" + str(x['ds']) + ";" + str(x['ns']) + ";" + str(x['nsec']) + ";" + str(x['rp']) + ";" + str(x['rrsig']) + ";" + str(x['soa']) + ";" + str(x['srv']) + ";" + str(x['txt']) + "\n"
			f.write(line)
					
	
	
	


