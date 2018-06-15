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
		#self.statistic.update(q.get())
		mergeDict(self.statistic,q.get())
		p.join()
		logging.info("Thread " + str(self.name) + " finished")
		#logging.info(str(self.statistic))
		self.running = False
		
def proc(q,arr1,arr2):
	statistic = {'new':{},'deleted':{},'newval':[],'delval':[]}
	todo = splitArr(arr1,arr2)
	for y in todo:
		for x in y[1]:
########################################################
#			if x not in y[0]:
#				try:
#					statistic['new'][x[2]] += 1
#				except:
#					statistic['new'][x[2]] = 1
#				statistic['newval'].append(x)
#			else:
#				y[0].remove(x)
########################################################
			i = 0
			while i < len(y[0]):
				#if x == y[0][i]:
				if x == y[0][i][1:]:
					break
				i += 1
			if i == len(y[0]):
				try:
					statistic['new'][x[2]] += 1
				except:
					statistic['new'][x[2]] = 1
				statistic['newval'].append(x)
			else:
				#y[0].remove(x)
				del y[0][i]
							
########################################################
		for x in y[0]:
			try:
				#statistic['deleted'][x[2]] += 1
				statistic['deleted'][x[3]] += 1
			except:
				#statistic['deleted'][x[2]] = 1
				statistic['deleted'][x[3]] = 1
			statistic['delval'].append(x)
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
						
				
def splitArr(arr1,arr2):
	if len(arr1) < 50000:
		return [[arr1,arr2]]
	dict1 = {'$':[],}
	dict2 = {'$':[],}
	for x in arr1:
		#if len(x[0]) <= 5:
		if len(x[1]) <= 5:
			dict1['$'].append(x)
		else:
			try:
				#dict1[x[0][:5]].append(x)
				dict1[x[1][:5]].append(x)
			except:
				#dict1[x[0][:5]] = [x]
				dict1[x[1][:5]] = [x]

	for x in arr2:
		if len(x[0]) <= 5:
			dict2['$'].append(x)
		else:
			try:
				dict2[x[0][:5]].append(x)
			except:
				dict2[x[0][:5]] = [x]
			
	for x in dict1:
		if x not in dict2:
			dict2[x] = []
	for x in dict2:
		if x not in dict1:
			dict1[x] = []	
		
	result = []
	for x in dict1:
		result.append([dict1[x],dict2[x]])
	return result		
				
				
				
				
				
				
		
