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
from zone2db import Zone2DB
from zone2db import SQLHelper

maxthreads = 18

def compare(zonefileone, zonefiletwo):

	#Init Logging
	LOGFILE = os.path.join(os.path.dirname(__file__),'..','var','comparezone2.log')
	logging.basicConfig(format='%(asctime)s [%(levelname)s]: %(message)s', filename=LOGFILE, level=logging.INFO)
	logging.info("compare started")
	
	tsOne = ZoneFileName2TS(zonefileone)
	tsTwo = ZoneFileName2TS(zonefiletwo)	
	logging.info("tsOne: " + str(tsOne))
	logging.info("tsTwo: " + str(tsTwo))
	
	z2dbOne = Zone2DB(zonefileone)
	z2dbTwo = Zone2DB(zonefiletwo)
	logging.info("Load zonefileone to dict")
	dictOne = z2dbOne.readDB2ABC()
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
		threads.append(Dict2Stat("Thread " + str(x)))
		
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
				logging.info("Start Thread " + str(x.getName()) + " for: " + procnow[0] + procnow[1] + ": " + str(len(dictTwo[procnow[0]][procnow[1]])))
				thread.start_new_thread(x.dict2stat, (copy.deepcopy(dictOne[procnow[0]][procnow[1]]), copy.deepcopy(dictTwo[procnow[0]][procnow[1]]),))
				#logging.info("thread should be started")
				
		if toprocess == []:
			#logging.info("nothing to process2")
			break
		#logging.info("going to sleep")
		time.sleep(0.5)
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
				
	stat = {'new':{},'deleted':{},'newval':[],'delval':[]}
	for x in threads:
		dict2stat.mergeDict(stat,x.getStats())
	logging.info("Statistic: \nNew:\n" + str(stat['new']) + "Delete:\n" + str(stat['deleted']))
	logging.info("New:\n" + str(stat['newval']))
	logging.info("Delete:\n" + str(stat['delval']))
				
	
	
	
	
	#dict2db(dictOne['x']['a'], dictTwo['x']['a'], tsTwo)
	
	
	
	
	
	



# extracts timestamp from zonefilename and returns it.
def ZoneFileName2TS(zonefile):
	ts = zonefile.split("/")[-1][:14]
	ts = ts[0:4] + "-" + ts[4:6] + "-" + ts[6:8] + " " + ts[8:10] + ":" + ts[10:12] + ":" + ts[12:14]
	return ts

if __name__ == "__main__":
	compare("../archives/se/20180406020001_zonedata.iis.se.zone", "../archives/se/20180407020001_zonedata.iis.se.zone")
