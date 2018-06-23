#!/bin/sh

DOMAIN=node.lyon.infa.co
NODES="zk1 zk2 zk3"
DNS_HOST=172.17.0.2

cnt=0

cat  zoo.cfg > zoo.cfg.multi
for i in `echo $NODES`; do
  cnt=$((cnt + 1));
  echo server.${cnt}=${i}.${DOMAIN}:2888:3888 >> zoo.cfg.multi
done

for i in `echo $NODES`; do
  docker run -d --name ${i} -h ${i}.${DOMAIN} --dns=${DNS_HOST} --dns-search=${DOMAIN} -v /home/docker-data/data/${i}:/export -v ${PWD}/zoo.cfg.multi:/usr/local/zookeeper/conf/zoo.cfg zookeeper-docker:3.4.11
done
