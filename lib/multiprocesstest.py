#!/usr/bin/env python
import multiprocessing as mp
import time

def foo(q):
	time.sleep(10)
	q.put('hello')
	time.sleep(5)
	
def bar():
	q = mp.Queue()
	p = mp.Process(target=foo, args=(q,))
	p.start()
	print(q.get())
	p.join()
