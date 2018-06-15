#!/usr/bin/env python
import psycopg2
from psycopg2.extras import execute_batch
import logging
import os
import sys
import copy
from datetime import datetime

sys.path.append(os.path.join(os.path.dirname(__file__),'..','etc'))
import settings


arrtmp = {
				'.':[],
				'_':[],
				'-':[],
				'0':[],
				'1':[],
				'2':[],
				'3':[],
				'4':[],
				'5':[],
				'6':[],
				'7':[],
				'8':[],
				'9':[],
				'a':[],
				'b':[],
				'c':[],
				'd':[],
				'e':[],
				'f':[],
				'g':[],
				'h':[],
				'i':[],
				'j':[],
				'k':[],
				'l':[],
				'm':[],
				'n':[],
				'o':[],
				'p':[],
				'q':[],
				'r':[],
				's':[],
				't':[],
				'u':[],
				'v':[],
				'w':[],
				'x':[],
				'y':[],
				'z':[]
				}
				
class Zone2DB(object):
	def __init__(self, zonefile):
		self.zonefile = zonefile
	
	def readZonefile(self):
		content = ""
		with open(self.zonefile) as f:
			content = f.readlines()
		return content
		
	def readZonefile2arr(self, maxsize=10000):
		arr = [[]]
		i = 0
		ai = 0
		with open(self.zonefile, "r") as f:
			for line in f:
				arr[ai].append(line)
				i += 1
				if i == maxsize:
					arr.append([])
					lastDomain = arr[ai][len(arr[ai]) -1].replace("\t"," ").split()[0]
					ii = 0
					while lastDomain == arr[ai][len(arr[ai]) -1].replace("\t"," ").split()[0]:
						arr[ai+1].append(arr[ai].pop())
						ii += 1
					i = ii
					ai += 1
		return arr
		
	def readZonefile2parsedArr(self):
		arr = []
		with open(self.zonefile, "r") as f:
			for line in f:
				line = line.split(";")
				if (len(line[0]) != 0):
					if (line[0] != "" and line[0] != "\n"):
						arr.append(self.recsplit(line[0]))
		return arr
		
	def readDB2ABC(self):
		db = SQLHelper("")
		dbresult = db.getAllActualRecs()
		arr = copy.deepcopy(arrtmp)
		for x in arr:
			arr[x] = copy.deepcopy(arrtmp)
		for x in dbresult:
			arr[x[1][0]][x[1][1]].append(list(x))
		del db
		return arr
		
		
		
		
		
		
		
	def readZoneFile2ABC(self):
		
				
		arr = copy.deepcopy(arrtmp)
		for x in arr:
			arr[x] = copy.deepcopy(arrtmp)
		
		
		
		
		with open(self.zonefile, "r") as f:
			for line in f:
				line = line.split(";")
				if (len(line[0]) != 0):
					if (line[0] != "" and line[0] != "\n"):
						rec = self.recsplit(line[0])
						
						arr[rec[0][0]][rec[0][1]].append(rec)
		return arr
				
				
				
				
				
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

class SQLHelper(object):
	def __init__(self, timestamp):
		self.conn = psycopg2.connect(settings.DBConnection)
		self.cur = self.conn.cursor()
		self.timestamp = timestamp

	def __del__(self):
		self.cur.close()
		self.conn.close()

	def upsertRectype(self, rec, fk_domain):
		self.cur.execute("SELECT id FROM rectype_" + rec[2].lower() + " WHERE fk_domain=%s AND ttl=%s AND value=%s AND deleted IS NULL", (fk_domain, rec[1], rec[3]))
		recid = self.cur.fetchone()
		if recid:
			self.cur.execute("UPDATE rectype_" + rec[2].lower() + " SET checked=%s RETURNING id", (self.timestamp))
		else:
			self.cur.execute("INSERT INTO rectype_" + rec[2].lower() + " (fk_domain,ttl,value,created,checked) VALUES (%s,%s,%s,%s,%s) RETURNING id", (fk_domain, rec[1], rec[3], self.timestamp, self.timestamp))
		rowid = self.cur.fetchone()[0]
		self.conn.commit()
		return rowid

	def selectDomainId(self,zonedict):
		for domain in zonedict:
			#logging.info("SELECT id FROM domain WHERE name="+str(domain)+" AND deleted IS NULL")
			self.cur.execute("SELECT id FROM domain WHERE name=%s AND deleted IS NULL", (domain,))
			recid = self.cur.fetchone()
			if recid:
				zonedict[domain]['fk'] = recid
				
	def upsertDomain(self, zonedict):
		for domain in zonedict:
			if zonedict[domain]['fk'] != 0:
				#logging.info("UPDATE domain SET checked="+str(self.timestamp)+" WHERE id="+str(zonedict[domain]['fk'])+" RETURNING id")
				self.cur.execute("UPDATE domain SET checked=%s WHERE id=%s RETURNING id", (self.timestamp, zonedict[domain]['fk']))
			else:
				#logging.info("INSERT INTO domain (name,created,checked) VALUES ("+str(domain)+","+str(self.timestamp)+","+str(self.timestamp)+") RETURNING id")
				self.cur.execute("INSERT INTO domain (name,created,checked) VALUES (%s,%s,%s) RETURNING id", (domain, self.timestamp, self.timestamp))
				zonedict[domain]['fk'] = self.cur.fetchone()[0]
		self.conn.commit()
		return
		
	def updateDomain(self, zonedict):
		params = []
		for domain in zonedict:
			params.append([self.timestamp, zonedict[domain]['fk']])
		execute_batch(self.cur, "UPDATE domain SET checked=%s WHERE id=%s", params)
		self.conn.commit()
		
	def updateDomain2(self,zonedict):
		for domain in zonedict:
			self.cur.execute("UPDATE domain SET checked=%s WHERE id=%s RETURNING id", (self.timestamp, zonedict[domain]['fk']))
			retid = self.cur.fetchone()[0]
			if zonedict[domain]['fk'] != retid:
				logging.error("fk id missmatch at " + domain + " expect " + str(zonedict[domain]['fk']) + " but received " + str(retid))
		self.conn.commit()
		
	def insertDomain(self, zonedict):
		for domain in zonedict:
			self.cur.execute("INSERT INTO domain (name,created,checked) VALUES (%s,%s,%s) RETURNING id", (domain, self.timestamp, self.timestamp))
			zonedict[domain]['fk'] = self.cur.fetchone()[0]
		self.conn.commit()
		
		
		
	def upsertDomain2(self,zonedict):
		params = []
		for domain in zonedict:
			params.append([domain,self.timestamp])
		execute_batch(self.cur, "SELECT upsert_domain(%s,%s)", params)
		self.conn.commit()
		
	def upsertRec(self, arr):
		for x in arr:
			if x[2] == "soa":
				pass
			else:
				self.cur.execute("SELECT upsert_" + x[2] + "(%s,%s,%s,%s)", (x[0], x[1], x[3], self.timestamp))
				if self.cur.fetchone()[0] == 0:
					logging.error("Could not upsert: " + str(x))
		self.conn.commit()
		
	def insertRecFlat(self, arr, ts):
		execute_batch(self.cur, "INSERT INTO recordflat (name,rectype,ttl,value,created) VALUES (%s,%s,%s,%s,'"+ts+"')", arr)
		self.conn.commit()
		
	def insertRecDiff(self, arr):
		execute_batch(self.cur, "INSERT INTO dnsdiff (name,ttl,rectype,value,created) VALUES (%s,%s,%s,%s,'"+self.timestamp+"')", arr)
		self.conn.commit()
	def updateRecDiff(self, arr, ts):
		execute_batch(self.cur, "UPDATE dnsdiff SET deleted = '"+ts+"' WHERE name=%s AND ttl=%s AND rectype=%s AND value=%s AND deleted IS NULL", arr)
		self.conn.commit()
		
	def getAllActualRecs(self):
		self.cur.execute("SELECT id,name,ttl,rectype,value FROM dnsdiff WHERE deleted IS NULL")
		return self.cur.fetchall()
		
	def delRecsById(self, arr):
		execute_batch(self.cur, "UPDATE dnsdiff SET deleted = '" + self.timestamp + "' WHERE id=%s", arr)



def badparse():
	content = readZonefile()
	sql = SQLHelper()
	for line in content:
		line = line.split(";")
		if (len(line[0]) != 0):
			if (line[0] != "" and line[0] != "\n"):
				rec = recsplit(line[0])
				if rec[2] != "SOA":
					domainid = sql.upsertDomain(rec[0])
					sql.upsertRectype(rec, domainid)



