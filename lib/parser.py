#!/usr/bin/env python
import logging


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
