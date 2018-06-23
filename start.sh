#!/bin/sh

DOMAIN=node.lyon.infa.co
NODES="zk2"
DNS_HOST=172.17.0.2

cnt=0

for i in `echo $NODES`; do
  docker run -d --name ${i} -h ${i}.${DOMAIN} --dns=${DNS_HOST} --dns-search=${DOMAIN} -e UPDATE_DNS=false -v /home/docker-data/data/${i}:/export zookeeper-docker:3.4.11
done
