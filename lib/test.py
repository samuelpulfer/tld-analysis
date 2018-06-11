#!/usr/bin/env python
import zone2db
import thread
import time
import os
import logging

maxthreads = 15
TIMESTAMP = "2018-04-05 22:46:11"

def doit3(zonefile):
	ts = zonefile.split("/")[-1][:14]
	ts = ts[0:4] + "-" + ts[4:6] + "-" + ts[6:8] + " " + ts[8:10] + ":" + ts[10:12] + ":" + ts[12:14]
	
	LOGFILE = os.path.join(os.path.dirname(__file__),'..','var','zone2db.log')
	logging.basicConfig(format='%(asctime)s [%(levelname)s]: %(message)s', filename=LOGFILE, level=logging.INFO)
	logging.info("doit2 started")
	z2d = zone2db.Zone2DB(zonefile)
	logging.info("reading zonefile to array")
	arr = z2d.readZonefile2arr(maxsize=100000000)
	db = zone2db.SQLHelper("000")
	db.insertRecDiff(cleanup(arr),ts)
	
def cleanup(arr):
	arrr2 = []
	lc =0
	rc =0
	for line in arr[0]:
			lc += 1
			line = line.split(";")
			if (len(line[0]) != 0):
				if (line[0] != "" and line[0] != "\n"):
					rec = recsplit(line[0])
					arrr2.append([rec[0],rec[1],rec[2],rec[3]])
					rc += 1
	print "lc: " + str(lc)
	print "rc: " + str(rc)				
	return arrr2


def recsplit(line):
		line = line.replace("\t"," ").split()
		value = ""
		for x in line[4:]:
			value = value + x + " "
		value = value[:len(value)-1]
		# return [domain, ttl, rectype, value]
		return [line[0], int(line[1]), line[3].lower(), value]










def doit2(zonefile):
	LOGFILE = os.path.join(os.path.dirname(__file__),'..','var','zone2db.log')
	logging.basicConfig(format='%(asctime)s [%(levelname)s]: %(message)s', filename=LOGFILE, level=logging.INFO)
	logging.info("doit2 started")
	z2d = zone2db.Zone2DB(zonefile)
	logging.info("reading zonefile to array")
	arr = z2d.readZonefile2arr()
	logging.info(str(len(arr)) + " packages to process")
	domainDict = {}
	threads = []
	# Prepare threads
	for x in range(0,maxthreads):
		threads.append(parsethread(TIMESTAMP,"Thread " + str(x)))
	# Select IDs	
	while arr != []:
		logging.info(str(len(arr)) + " packages to process")
		for x in threads:
			if x.isRunning() == False:
				if arr == []:
					break
				thread.start_new_thread(x.parse2, (arr.pop(),))
		if arr == []:
			break
		time.sleep(2)

def doit(zonefile):
	LOGFILE = os.path.join(os.path.dirname(__file__),'..','var','zone2db.log')
	logging.basicConfig(format='%(asctime)s [%(levelname)s]: %(message)s', filename=LOGFILE, level=logging.INFO)
	z2d = zone2db.Zone2DB(zonefile)
	logging.info("reading zonefile to array")
	arr = z2d.readZonefile2arr()
	logging.info(str(len(arr)) + " packages to process")
	domainDict = {}
	threads = []
	# Prepare threads
	for x in range(0,maxthreads):
		threads.append(parsethread(TIMESTAMP,"Thread " + str(x)))
	# Select IDs	
	while arr != []:
		logging.info(str(len(arr)) + " packages to process")
		for x in threads:
			if x.isRunning() == False:
				if arr == []:
					break
				thread.start_new_thread(x.parse, (arr.pop(),))
		if arr == []:
			break
		time.sleep(0.2)

			
	# Write to db
	logging.info("################## Update DB ##################")
	for x in threads:
		thread.start_new_thread(x.splitUpdateInsert,("",))
		
	# Wait untill all threads finished
	tstop = maxthreads
	while tstop != 0:
		tstop = maxthreads
		for x in threads:
			if x.isRunning() == False:
				tstop -= 1
	allZoneDict = {}
	for x in threads:
		allZoneDict.update(x.getZoneDictResult())
	
	return allZoneDict
"""
	sql = parsethread(TIMESTAMP,"Thread 0")
	while arr!= []:
		logging.info(str(len(arr)) + " packages to process")
		sql.parse(arr.pop())
"""
class parsethread(object):
	def __init__(self, timestamp, name):
		self.name = name
		self.running = False
		self.sqlh = zone2db.SQLHelper(timestamp)
		self.zoneDictResult = {}
		self.zoneDictUpdate = {}
		logging.info("Thread: " + self.name + " created.")
		
	def __del__(self):
		logging.info("Thread: " + self.name + " deleted.")
		del self.sqlh
		
	def isRunning(self):
		return self.running

	def getZoneDictResult(self):
		return {self.name:{'insert':self.zoneDictResult, 'update':self.zoneDictUpdate}}
		
	def splitUpdateInsert(self, something):
		while self.running == True:
			time.sleep(1)
		self.running = True
		for x in self.zoneDictResult.keys():
			if self.zoneDictResult[x]['fk'] != 0:
				self.zoneDictUpdate[x] = dict(self.zoneDictResult[x])
				del self.zoneDictResult[x]
		self.update()
		self.insert()
		self.running = False
		
	def recsplit(self, line):
		line = line.replace("\t"," ").split()
		value = ""
		for x in line[4:]:
			value = value + x + " "
		value = value[:len(value)-1]
		# return [domain, ttl, rectype, value]
		return [line[0], int(line[1]), line[3].lower(), value]
	
	def parseLineArr(self, lineArr):
		zonedict = dict()
		for line in lineArr:
			line = line.split(";")
			if (len(line[0]) != 0):
				if (line[0] != "" and line[0] != "\n"):
					rec = self.recsplit(line[0])
					try:
						zonedict[rec[0]]['recs'].append([rec[2],rec[1],rec[3]])
					except:
						zonedict[rec[0]] = {'fk': 0, 'recs': [[rec[2],rec[1],rec[3]]]}
		return zonedict
		
	def parse(self, arr):
		self.running = True
		logging.info("Thread: " + self.name + " started.")
		logging.info("Thread: " + self.name + " parsing array.")
		zonedict = self.parseLineArr(arr)
		try:
			logging.info("Thread: " + self.name + " query domain PKs.")
			self.sqlh.selectDomainId(zonedict)
			#logging.info("Thread: " + self.name + " upsert domains.")
			#self.sqlh.upsertDomain2(zonedict)
			logging.info("Thread: " + self.name + " query domains finished.")
			self.zoneDictResult.update(zonedict)
		except Exception, e:
			logging.error("Thread: " + self.name + " query domain or upsert failed.")
			logging.error("Thread: " + self.name + " " + str(e))
		self.running = False
			
	def parse2(self, arr):
		self.running = True
		logging.info("Thread: " + self.name + " started.")
		linearr = []
		for x in arr:
			linearr.append(self.recsplit(x))
		self.sqlh.upsertRec(linearr)
		logging.info("Thread: " + self.name + " finished.")
		self.running = False
		
		
		
		
		
	def update(self):
		#self.running = True
		logging.info("Thread: " + self.name + " " + str(len(self.zoneDictUpdate)) + " to update.")
		self.sqlh.updateDomain(self.zoneDictUpdate)
		logging.info("Thread: " + self.name + " update domains finished.")
		#self.running = False
		
	def insert(self):
		#self.running = True
		logging.info("Thread: " + self.name + " " + str(len(self.zoneDictResult)) + " to insert.")
		self.sqlh.insertDomain(self.zoneDictResult)
		logging.info("Thread: " + self.name + " insert domains finished.")
		#self.running = False		
		
		
if __name__ == "__main__":
	doit3("../archives/se/20180407020001_zonedata.iis.se.zone")
		
		
