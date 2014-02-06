#!/bin/bash
for i in `seq 1 9`;do ssh broker$i /root/kafka-0.8.0-src/bin/kafka-server-stop.sh ; done
for i in `seq 1 9`;do ssh broker$i "rm -rf /tmp/kafka-logs/*" ; done
/opt/zookeeper/bin/zkCli.sh -server jcr1.jcfernandez.cediant.es:2181 rmr /brokers/topics/PERF
for i in `seq 1 9`;do ssh broker$i "hostname;netstat -atunp| grep 9092"; done
