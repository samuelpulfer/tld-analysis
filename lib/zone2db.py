#!/usr/bin/env python
import psycopg2
import logging
import os
import sys
from datetime import datetime

zonefile = "zonedata.iis.se.zone"

domaindict = {'fk': 0, 'recs': []}

class Zone2DB(object):
	def __init__(self, zonefile):
		self.zonefile = zonefile
	
	def readZonefile(self):
		content = ""
		with open(self.zonefile) as f:
			content = f.readlines()
		return content
		
	def readZonefile2arr(self, maxsize=10000):
		content = self.readZonefile()
		arr = []
		i = 0
		for line in content:
			try:
				arr[i/maxsize].append(line)
				i += 1
			except:
				arr.append([])
				arr[i/maxsize].append(line)
				i += 1
		del content
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
		self.conn = psycopg2.connect("dbname='dns'")
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
			self.cur.execute("SELECT id FROM domain WHERE name=%s AND deleted IS NULL", (domain,))
			recid = self.cur.fetchone()
			if recid:
				zonedict[domain]['fk'] = recid
				
	def upsertDomain(self, zonedict):
		for domain in zonedict:
			if zonedict[domain]['fk'] != 0:
				self.cur.execute("UPDATE domain SET checked=%s WHERE id=%s RETURNING id", (self.timestamp, zonedict[domain]['fk']))
			else:
				self.cur.execute("INSERT INTO domain (name,created,checked) VALUES (%s,%s,%s) RETURNING id", (domain, self.timestamp, self.timestamp))
				domain['fk'] = self.cur.fetchone()[0]
		self.conn.commit()
		return




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



