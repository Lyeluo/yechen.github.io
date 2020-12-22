#!/bin/bash -e
# Prints the name of the container inside which the process with a PID on the host is.
for i in  `docker ps |grep Up|awk '{print $1}'`;do echo \ &&docker top $i &&echo ID=$i; done |grep -A 10 <PID>

