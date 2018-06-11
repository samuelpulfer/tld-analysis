#!/usr/bin/env python
import os
import sys
import logging
import thread
import time



class Dict2DB(object):
	def __init__(self, name):
		self.name = name
		self.running = False
		#self.sqlh = SQLHelper("0000")
		self.statistic = {'new':{},'deleted':{}}
		logging.info("Thread: " + self.name + " created.")
		
	def __del__(self):
		logging.info("Thread: " + self.name + " deleted.")
		#del self.sqlh
		
	def isRunning(self):
		return self.running
	
	def getName(self):
		return self.name
		
	def getStats(self):
		return self.statistic
		
	def dict2stat(self, arr1, arr2):
		self.running = True
		diff = []
		for x in arr2:
			if x not in arr1:
				try:
					self.statistic['new'][x[2]] += 1
				except:
					self.statistic['new'][x[2]] = 1
			else:
				try:
					self.statistic['deleted'][x[2]] += 1
				except:
					self.statistic['deleted'][x[2]] = 1
				arr1.remove(x)
		logging.info("Thread " + str(self.name) + " finished")
		logging.info(str(self.statistic))
		self.running = False
		
	def dict2stat2(self, toprocess, dictOne, dictTwo):
		self.running = True
		while toprocess != []:
			curr = toprocess.pop()
			logging.info("Thread " + str(self.name) + " started: " + curr[0] + curr[1])
			arr1 = dictOne[curr[0]][curr[1]]
			arr2 = dictTwo[curr[0]][curr[1]]
			for x in arr2:
				if x not in arr1:
					try:
						self.statistic['new'][x[2]] += 1
					except:
						self.statistic['new'][x[2]] = 1
				else:
					try:
						self.statistic['deleted'][x[2]] += 1
					except:
						self.statistic['deleted'][x[2]] = 1
					arr1.remove(x)
			logging.info("Thread " + str(self.name) + " stopped: " + curr[0] + curr[1])
		logging.info("Thread " + str(self.name) + " finished")
		
"""			
	def dict2db(self, arr1, arr2, ts):
		self.running = True
		diff = []
		for x in arr2:
			if x not in arr1:
				diff.append(x)
			else:
				arr1.remove(x)
		
		logging.info("Thread " + str(self.name) + " writing new records to db: " + str(len(diff)))
		try:
			if diff != []:
				self.sqlh.insertRecDiff(diff, ts)
		except Exception, e:
			logging.info("Thread " + str(self.name) + " can't write to db: " + str(e))
			
	
		logging.info("Thread " + str(self.name) + " update old records in db: " + str(len(arr1)))
		try:
			if arr1 != []:
				self.sqlh.updateRecDiff(arr1, ts)
		except Exception, e:
			logging.info("Thread " + str(self.name) + " can't update db: " + str(e))
			
		self.running = False
"""

