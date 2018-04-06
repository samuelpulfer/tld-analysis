#!/usr/bin/env python
import zone2db
import thread
import time
import os
import logging

maxthreads = 10
TIMESTAMP = "2018-04-05 22:46:11"

def doit(zonefile):
	LOGFILE = os.path.join(os.path.dirname(__file__),'..','var','zone2db.log')
	logging.basicConfig(format='%(asctime)s %(message)s', filename=LOGFILE, level=logging.INFO)
	z2d = zone2db.Zone2DB(zonefile)
	logging.info("reading zonefile to array")
	arr = z2d.readZonefile2arr()
	logging.info(str(len(arr)) + " packages to process")
	
	threads = []
	for x in range(0,maxthreads):
		threads.append(parsethread(TIMESTAMP,"Thread " + str(x)))
		
	while arr != []:
		logging.info(str(len(arr)) + " packages to process")
		for x in threads:
			if x.isRunning() != True:
				thread.start_new_thread(x.parse, (arr.pop(),))
				break
		time.sleep(1)
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
		logging.info("Thread: " + self.name + " created.")
		
	def __del__(self):
		logging.info("Thread: " + self.name + " deleted.")
		del self.sqlh
		
	def isRunning(self):
		return self.running
		
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
			logging.info("Thread: " + self.name + " upsert domains.")
			self.sqlh.upsertDomain(zonedict)
			logging.info("Thread: " + self.name + " upsert domains finished.")
		except Exception, e:
			logging.error("Thread: " + self.name + " query domain or upsert failed.")
			logging.error("Thread: " + self.name + " " + str(e))
		self.running = False
			

		
		
		
		
		
		
		
		
