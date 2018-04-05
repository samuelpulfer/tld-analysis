#!/usr/bin/env python
from datetime import datetime
import logging
import os
import sys
import subprocess

sys.path.append(os.path.join(os.path.dirname(__file__),'..','etc'))
sys.path.append(os.path.join(os.path.dirname(__file__),'..','lib'))

import zoneconfig


class Zonetransfer(object):
	def __init__(self):
		self.archives = os.path.join(os.path.dirname(__file__),'..','archives')
		# initialize logger
		LOGFILE = os.path.join(os.path.dirname(__file__),'..','var','zonetransfer.log')
		logging.basicConfig(format='%(asctime)s %(message)s', filename=LOGFILE, level=logging.INFO)
		# get timestamp
		self.now = datetime.now()
	
	def get_dig_axfr_output(self, hostname, nameserver):
		logging.info("Start zonetransfer for %s on %s" %(hostname, nameserver))
		proc = subprocess.Popen(["/usr/bin/dig", "AXFR", hostname, "@" + nameserver, "+nocomments", "+nocmd", "+noquestion", "+nostats", "+time=15"], stdout=subprocess.PIPE)
		output = proc.stdout.read()
		return output
		
	def zone_transfer_succeeded(self, zone_data):
		if "Transfer failed." in zone_data:
			logging.error(zone_data)
			return False
		if "failed: connection refused." in zone_data:
			logging.error(zone_data)
			return False
		if "communications error" in zone_data:
			logging.error(zone_data)
			return False
		if "failed: network unreachable." in zone_data:
			logging.error(zone_data)
			return False
		if "failed: host unreachable." in zone_data:
			logging.error(zone_data)
			return False
		if "connection timed out; no servers could be reached" in zone_data:
			logging.error(zone_data)
			return False
		if zone_data == "":
			logging.error("Unknown error")
			return False
		logging.info("Zonetransfer succeeded")
		return True
		
	def write_dig_output(self, hostname, nameserver, dig_output):
		if hostname == ".":
			hostname = "root"
		if hostname.endswith( "." ):
			dir_path = os.path.join(self.archives, hostname[:-1])
		else:
			dir_path = os.path.join(self.archives, hostname)
		if not os.path.exists( dir_path ):
			os.makedirs( dir_path )
		filename = os.path.join(dir_path, now.strftime("%Y%m%d%H%M%S") + nameserver + "zone")
		logging.info("Write zonefile to " + filename)
		file_handler = open( filename, "w" )
		file_handler.write(
			dig_output
		)
		file_handler.close()
    	
	def transfer(self):
		for zone in zoneconfig.ZONE:
			zone_data = self.get_dig_axfr_output(zone,zoneconfig.ZONE[zone])
			if self.zone_transfer_succeeded(zone_data):
				self.write_dig_output(zone, zoneconfig.ZONE[zone], zone_data)
				

	



if __name__ == "__main__":
	a = Zonetransfer()
	a.transfer()


