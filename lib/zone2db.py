#!/usr/bin/env python
import psycopg2

zonefile = "zonedata.iis.se.zone"

def recsplit(line):
	line = line.replace("\t"," ").split()
	domain = line[0]
	ttl = int(line[1])
	rectype = line[3]
	value = ""
	for x in line[4:]:
		value = value + x + " "
	value = value[:len(value)-1]
	return [domain, ttl, rectype, value]

def readZonefile():
	content = ""
	with open(zonefile) as f:
		content = f.readlines()
	return content

class SQLHelper:
	def __init__(self):
		self.conn = psycopg2.connect("dbname='dnsexample' user='dnsuser' host='localhost' password='dnspwd'")
		self.cur = self.conn.cursor()
		self.timestamp = self.__getTimestamp()

	def __del__(self):
		self.cur.close()
		self.conn.close()

	def __getTimestamp(self):
		self.cur.execute("SELECT now()")
		return self.cur.fetchone()

	def getTimestamp(self):
		return self.timestamp

	def upsertRectype(self, rec, fk_domain):
		self.cur.execute("SELECT id FROM rectype_" + rec[2].lower() + " WHERE fk_domain=%s AND ttl=%s AND value=%s AND deleted IS NULL", (fk_domain, rec[1], rec[3]))
		recid = self.cur.fetchone()
		if recid:
			self.cur.execute("UPDATE rectype_" + rec[2].lower() + " SET modified=%s RETURNING id", (self.timestamp))
		else:
			self.cur.execute("INSERT INTO rectype_" + rec[2].lower() + " (fk_domain,ttl,value,created,modified) VALUES (%s,%s,%s,%s,%s) RETURNING id", (fk_domain, rec[1], rec[3], self.timestamp, self.timestamp))
		rowid = self.cur.fetchone()[0]
		self.conn.commit()
		return rowid

	def upsertDomain(self, domain):
		self.cur.execute("SELECT id FROM domain WHERE name=%s AND deleted IS NULL", (domain,))
		recid = self.cur.fetchone()
		if recid:
			self.cur.execute("UPDATE domain SET modified=%s WHERE id=%s RETURNING id", (self.timestamp, recid))
		else:
			self.cur.execute("INSERT INTO domain (name,created,modified) VALUES (%s,%s,%s) RETURNING id", (domain, self.timestamp, self.timestamp))
		self.conn.commit()
		rowid = self.cur.fetchone()[0]
		return rowid




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



"""



lastdomain = ["",0]
for line in content:
	line = line.split(";")
	if (len(line[0]) != 0):
		if (line[0] != "" and line[0] != "\n"):
			rec = recsplit(line[0])
			if rec[2] != "SOA":
				cur = conn.cursor()
				if rec[0] == lastdomain[0]:
					cur.execute("INSERT INTO rectype_" + rec[2].lower() + " (fk_domain, ttl, value, created, modified) VALUES (?,?,?,?,now())", (rec[0],int(rec[1]),rec[3],rec[4]))
	conn.commit()


fk_domain bigint,
  ttl INTEGER NOT NULL,
  value character varying(255) NOT NULL,
  created timestamp without time zone,
  modified timestamp without time zone,
  deleted timestamp without time zone

"""
