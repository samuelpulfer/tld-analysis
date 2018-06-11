#!/usr/bin/env python
import zone2db
import thread
import time
import os
import logging

maxthreads = 10
TIMESTAMP = "2018-04-05 22:46:11"


def doit():
	# Init
	LOGFILE = os.path.join(os.path.dirname(__file__),'..','var','zone2db.log')
	logging.basicConfig(format='%(asctime)s [%(levelname)s]: %(message)s', filename=LOGFILE, level=logging.INFO)
	logging.info("doit2 started")
	
	# Read zonefile and split it in multiple arrays
	
	
	
	
	
	
