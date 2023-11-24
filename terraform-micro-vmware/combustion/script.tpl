#!/bin/bash
## disabled "network" in combustion due to race condition "igition" vs "combustion" vs "static network"
# c#ombustion: network
echo ${servername} > /root/combustion-was-here
