#!/usr/bin/env python
import os
import sys
import logging
import thread
import time
import copy

sys.path.append(os.path.join(os.path.dirname(__file__),'..','lib'))

from dict2db import Dict2DB
from dict2stat import Dict2Stat
import dict2stat
from zone2db import Zone2DB
from zone2db import SQLHelper

maxthreads = 18

def compare(zonefileone, zonefiletwo):

	tsOne = ZoneFileName2TS(zonefileone)
	tsTwo = ZoneFileName2TS(zonefiletwo)

	#Init Logging
	LOGFILE = os.path.join(os.path.dirname(__file__),'..','var','comparezone'+tsTwo+'.log')
	logging.basicConfig(format='%(asctime)s [%(levelname)s]: %(message)s', filename=LOGFILE, level=logging.INFO)
	logging.info("compare started")
	
		
	logging.info("tsOne: " + str(tsOne))
	logging.info("tsTwo: " + str(tsTwo))
	
	z2dbOne = Zone2DB(zonefileone)
	z2dbTwo = Zone2DB(zonefiletwo)
	logging.info("Load zonefileone to dict")
	dictOne = z2dbOne.readDB2ABC()
	#dictOne = z2dbOne.readZoneFile2ABC()
	logging.info("Load zonefiletwo to dict")
	dictTwo = z2dbTwo.readZoneFile2ABC()
	
	#create diff
	logging.info("create diff")
	#logging.info("Length zonefileone: " + str(len(arrOne)))
	#logging.info("Length zonefiletwo: " + str(len(arrTwo)))
	
	toprocess = []
	
	for x in dictTwo:
		for y in dictTwo[x]:
			toprocess.append([x,y])
	threads = []
	#prepare threads
	for x in range(0,maxthreads):
		threads.append(dict2stat.Dict2Stat(str(x)))
		
#	for x in threads:
#		thread.start_new_thread(x.dict2stat2, (toprocess,dictOne,dictTwo,))
	##############

	while toprocess != []:
		#logging.info("heartbeat")
		for x in threads:
			#logging.info("looping threads")
			if x.isRunning() == False:
				#logging.info("Thread ready")
				if toprocess == []:
					#logging.info("nothing to process")
					break
				procnow = toprocess.pop()
				logging.info("Thread " + str(x.getName()) + " started for: " + procnow[0] + procnow[1] + ": " + str(len(dictTwo[procnow[0]][procnow[1]])))
				#thread.start_new_thread(x.dict2stat, (copy.deepcopy(dictOne[procnow[0]][procnow[1]]), copy.deepcopy(dictTwo[procnow[0]][procnow[1]]),))
				thread.start_new_thread(x.dict2stat, (dictOne[procnow[0]][procnow[1]], dictTwo[procnow[0]][procnow[1]],))
				#logging.info("thread should be started")
				
		if toprocess == []:
			#logging.info("nothing to process2")
			break
		#logging.info("going to sleep")
		time.sleep(0.1)
	##############
	logging.info("tsOne: " + tsOne)
	logging.info("tsTwo: " + tsTwo)
	#logging.info("All done with " + str(errors) + " errors")
	
	x = maxthreads
	while x != 0:
		x = maxthreads
		for y in threads:
			if y.isRunning() == False:
				x -= 1
		time.sleep(2)
	logging.info("All threads finished")
				
	stat = {'new':{},'deleted':{},'newval':[],'delval':[]}
	for x in threads:
		dict2stat.mergeDict(stat,x.getStats())
	logging.info("Statistic: \nNew:\n" + str(stat['new']) + "Delete:\n" + str(stat['deleted']))
	#with open("../var/new"+tsTwo+".txt","w") as f:
	#	f.write(str(stat['newval']))
	#with open("../var/del"+tsTwo+".txt","w") as f:
	#	f.write(str(stat['delval']))
	#with open("../var/stat"+tsTwo+".txt","w") as f:
	#	f.write(str(stat['new']) + "\nDelete:\n" + str(stat['deleted']))
	
	# Write changes to db
	#sqlh = SQLHelper("")
	#logging.info("Update old records in DB")
	#sqlh.updateRecDiff(stat['delval'], tsTwo)
	#logging.info("Insert new records to DB")
	#sqlh.insertRecDiff(stat['newval'], tsTwo)
	stats2file(stat,tsOne,tsTwo)
	
	del dictOne
	del dictTwo
	del threads
	logging.info("All done")
	
# CSV Helper
def stats2file(stats,ts1,ts2):
	folder = "../archives/stat/" + ts1 + "_to_" +ts2
	if not os.path.exists(folder):
		os.makedirs(folder)
	#logging.info("Write new.csv")
	
	newval = {}
	for x in stats['newval']:
		try:
			newval[x[2]].append(x)
		except:
			newval[x[2]] = [x]
	delval = {}
	for x in stats['delval']:
		try:
			#delval[x[2]].append(x)
			delval[x[3]].append(x)
		except:
			#delval[x[2]] = [x]
			delval[x[3]] = [x]
	for x in newval:
		with open(folder + "/new_" + x + ".csv", "w") as f:
			for y in newval[x]:
				f.write(y[0]+";"+str(y[1])+";"+y[2]+";"+y[3] + "\n")
	for x in delval:
		with open(folder + "/del_" + x + ".csv", "w") as f:
			for y in delval[x]:
				f.write(str(y[0])+";"+y[1]+";"+str(y[2])+";"+y[3]+";"+y[4]+ "\n")
	logging.info("Write stat.txt")
	with open(folder + "/stat.txt","w") as f:
		f.write("New:\n" + str(stats['new']) + "\nDelete:\n" + str(stats['deleted']))
		
		
	#Update DB
	logging.info("Update DB")
	update = []
	for x in stats['delval']:
		update.append(x[:1])
	db = SQLHelper(ts2)
	db.delRecsById(update)
	
	logging.info("Insert new Records to DB")
	db.insertRecDiff(stats['newval'])
	
	
	
	
	
	
	



# extracts timestamp from zonefilename and returns it.
def ZoneFileName2TS(zonefile):
	ts = zonefile.split("/")[-1][:14]
	ts = ts[0:4] + "-" + ts[4:6] + "-" + ts[6:8] + " " + ts[8:10] + ":" + ts[10:12] + ":" + ts[12:14]
	return ts

if __name__ == "__main__":
	compare("../archives/se/20180406020001_zonedata.iis.se.zone", "../archives/se/20180407020001_zonedata.iis.se.zone")
