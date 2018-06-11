#!/usr/bin/env python
import os
import sys
import logging
import multiprocessing as mp
import time



class Dict2Stat(object):
	def __init__(self, name):
		self.name = name
		self.running = False
		#self.sqlh = SQLHelper("0000")
		self.statistic = {'new':{},'deleted':{},'newval':[],'delval':[]}
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
		q = mp.Queue()
		p = mp.Process(target=proc, args=(q,arr1,arr2,))
		p.start()
		self.statistic.update(q.get())
		p.join()
		logging.info("Thread " + str(self.name) + " finished")
		#logging.info(str(self.statistic))
		self.running = False
		
def proc(q,arr1,arr2):
	statistic = {'new':{},'deleted':{},'newval':[],'delval':[]}
	for x in arr2:
		if x not in arr1:
			try:
				statistic['new'][x[2]] += 1
			except:
				statistic['new'][x[2]] = 1
			statistic['newval'].append(x)
		else:
			try:
				statistic['deleted'][x[2]] += 1
			except:
				statistic['deleted'][x[2]] = 1
			statistic['delval'].append(x)
			arr1.remove(x)
	q.put(statistic)
				
				
def mergeDict(dict1, dict2):
	for x in dict2['new']:
		if x not in dict1['new']:
			dict1['new'][x] = dict2['new'][x]
		else:
			dict1['new'][x] += dict2['new'][x]
	for x in dict2['deleted']:
		if x not in dict1['deleted']:
			dict1['deleted'][x] = dict2['deleted'][x]
		else:
			dict1['deleted'][x] += dict2['deleted'][x]
	for x in dict2['newval']:
		dict1['newval'].append(x)
	for x in dict2['delval']:
		dict1['delval'].append(x)
						
				
				
				
				
				
				
				
				
		
