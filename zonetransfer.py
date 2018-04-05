#!/usr/bin/env python
import subprocess
import dns.resolver
import dns.zone
import dns.query
#import tldextract
import requests
import argparse
import random
import socket
import string
import signal
import time
import json
import sys
import os
from contextlib import contextmanager

ROOT_NAMESERVER_LIST = [
    "e.root-servers.net.",
    "h.root-servers.net.",
    "l.root-servers.net.",
    "i.root-servers.net.",
    "a.root-servers.net.",
    "d.root-servers.net.",
    "c.root-servers.net.",
    "b.root-servers.net.",
    "j.root-servers.net.",
    "k.root-servers.net.",
    "g.root-servers.net.",
    "m.root-servers.net.",
    "f.root-servers.net.",
]

GLOBAL_DNS_CACHE = {
    "A": {},
    "NS": {},
    "CNAME": {},
    "SOA": {},
    "WKS": {},
    "PTR": {},
    "MX": {},
    "TXT": {},
    "RP": {},
    "AFSDB": {},
    "SRV": {},
    "A6": {},
}

def get_dig_axfr_output( hostname, nameserver ):
    proc = subprocess.Popen([
        "/usr/bin/dig", "AXFR", hostname, "@" + nameserver, "+nocomments", "+nocmd", "+noquestion", "+nostats", "+time=15"
    ], stdout=subprocess.PIPE)
    output = proc.stdout.read()
    return output



def zone_transfer_succeeded( zone_data ):
    if "Transfer failed." in zone_data:
        return False
    if "failed: connection refused." in zone_data:
        return False
    if "communications error" in zone_data:
        return False
    if "failed: network unreachable." in zone_data:
        return False
    if "failed: host unreachable." in zone_data:
        return False
    if "connection timed out; no servers could be reached" in zone_data:
        return False
    if zone_data == "":
        return False
    return True

def write_dig_output( hostname, nameserver, dig_output ):
    if hostname == ".":
        hostname = "root"
    if hostname.endswith( "." ):
        dir_path = "./archives/" + hostname[:-1] + "/"
    else:
        dir_path = "./archives/" + hostname + "/"
    if not os.path.exists( dir_path ):
        os.makedirs( dir_path )
    filename = dir_path + nameserver + "zone"
    file_handler = open( filename, "w" )
    file_handler.write(
        dig_output
    )
    file_handler.close()

def get_root_tlds():
    response = requests.get( "https://data.iana.org/TLD/tlds-alpha-by-domain.txt", )
    lines = response.text.split( "\n" )
    tlds = []
    for line in lines:
        if not "#" in line and not line == "":
            tlds.append( line.strip().lower() )
    return tlds

zone_transfer_enabled_list = []

for root_ns in ROOT_NAMESERVER_LIST:
    zone_data = get_dig_axfr_output(
        ".",
        root_ns,
    )
    if zone_transfer_succeeded( zone_data ):
        zone_transfer_enabled_list.append({
            "nameserver": root_ns,
            "hostname": "."
        })
    write_dig_output(
            ".",
            root_ns,
            zone_data,
        )
    tlds = get_root_tlds()


