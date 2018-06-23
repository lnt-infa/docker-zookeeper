# Creates pseudo distributed hadoop 2.7.1
#

FROM sequenceiq/pam:centos-6.5
MAINTAINER LNT

USER root

ARG ZOOKEEPER_VERSION
ENV ZOOKEEPER_VERSION=${ZOOKEEPER_VERSION:-3.4.12}


# install dev tools
RUN yum clean all; \
    rpm --rebuilddb; \
    yum install -y curl which tar sudo openssh-server openssh-clients rsync
# update libselinux. see https://github.com/sequenceiq/hadoop-docker/issues/14
RUN yum update -y libselinux

# passwordless ssh
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys


# java
RUN curl -LO 'http://download.oracle.com/otn-pub/java/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/jdk-8u171-linux-x64.rpm' -H 'Cookie: oraclelicense=accept-securebackup-cookie'
RUN rpm -i jdk-8u171-linux-x64.rpm
RUN rm jdk-8u171-linux-x64.rpm

ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin
RUN rm /usr/bin/java && ln -s $JAVA_HOME/bin/java /usr/bin/java


# download zookeeper
RUN curl -s http://www.eu.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s zookeeper-${ZOOKEEPER_VERSION} zookeeper
ENV ZOO_HOME /usr/local/zookeeper
ENV PATH $PATH:$ZOO_HOME/bin
#RUN mv $ZOO_HOME/conf/zoo_sample.cfg $ZOO_HOME/conf/zoo.cfg
ADD zoo.cfg /usr/local/zookeeper/conf/zoo.cfg

ARG EXPORT_PREFIX=/export

ENV ZOO_LOG_DIR $EXPORT_PREFIX/log/zookeeper

ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config

# run each component with different user.
RUN groupadd -r hadoop 
RUN useradd -r -g hadoop zookeeper && mkdir -p /home/zookeeper && chown zookeeper: /home/zookeeper && cp -r /root/.ssh /home/zookeeper/.ssh && chown -R zookeeper: /home/zookeeper/.ssh

RUN for u in `echo zookeeper`; do cp /etc/skel/.bashrc /home/$u/.bashrc && chown $u: /home/$u/.bashrc; done

RUN echo "export JAVA_HOME=/usr/java/default" >> /etc/profile.d/hadoop-env.sh

RUN echo @hadoop	soft nproc unlimited >> /etc/security/limits.conf
RUN echo @hadoop	hard nproc unlimited >> /etc/security/limits.conf

RUN echo "export ZOO_LOG_DIR=$ZOO_LOG_DIR"  >> /etc/profile.d/hadoop-env.sh

RUN echo "export EXPORT_PREFIX=$EXPORT_PREFIX" >> /etc/profile.d/hadoop-env.sh

RUN chmod 755 /etc/profile.d/hadoop-env.sh

RUN curl -LO https://raw.githubusercontent.com/lnt-infa/docker-common-scripts/master/consulFunctions.sh && cp consulFunctions.sh /etc/consulFunctions.sh

ADD bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

ENV BOOTSTRAP /etc/bootstrap.sh

CMD ["/etc/bootstrap.sh", "-d"]

# Zookeeper
EXPOSE 2181
