#!/bin/bash -x

: ${ZOO_HOME:=/usr/local/zookeeper}
: ${EXPORT_PREFIX:=/export}

source /etc/consulFunctions.sh

rm /tmp/*.pid

#service sshd start

# creating the log dirs
mkdir -p $ZOO_LOG_DIR && chown zookeeper: $ZOO_LOG_DIR

# creating data dir
for u in `echo zookeeper`; do mkdir -p $EXPORT_PREFIX/data/$u && chown $u: $EXPORT_PREFIX/data/$u; done

h=`hostname -a`
cat ${ZOO_HOME}/conf/zoo.cfg | grep ${h} | awk -F'.' '{print($2)}' | awk -F'='  '{print($1)}' > $EXPORT_PREFIX/data/zookeeper/myid

sleep 10

mkdir /tmp/zookeeper
chown zookeeper: /tmp/zookeeper 
su zookeeper -c "$ZOO_HOME/bin/zkServer.sh start"

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
