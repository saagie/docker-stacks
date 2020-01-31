# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG BASE_CONTAINER=jupyter/scipy-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Saagie"

USER root

# Spark dependencies
ENV APACHE_SPARK_VERSION 2.3.0
ENV SPARK_VERSION 2.3.0-cloudera4
ENV HADOOP_VERSION 2.6
# On debian slim needs mkdir man directory to avoid installation errors
RUN mkdir -p /usr/share/man/man1 && \
    apt-get -y update && \
    apt-get install --no-install-recommends -y \
      openjdk-8-jre-headless ca-certificates-java && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#Installing Spark
RUN wget https://nexus.saagie.tech/service/local/repositories/thirdparty/content/org/apache/spark/2.3.0.cloudera4/spark-2.3.0.cloudera4.tgz -P /tmp \
    && tar -zxf /tmp/spark-2.3.0.cloudera4.tgz -C /usr/local/  \
    && ln -s /usr/local/spark-2.3.0.cloudera4-bin-spark2.3.0-saagie/ /usr/local/spark \
    && ln -s /usr/local/spark-2.3.0.cloudera4-bin-spark2.3.0-saagie/ /usr/local/spark2 \
    && rm /tmp/spark-2.3.0.cloudera4.tgz
  
# Mesos dependencies
COPY mesos.key /tmp/
# PATCH for issue MARATHON-7694 (https://jira.mesosphere.com/browse/MARATHON-7694)
RUN touch /usr/local/bin/systemctl && chmod +x /usr/local/bin/systemctl

RUN apt-get update -qq && apt-get install -yqq --no-install-recommends \
      libcurl3 libevent-dev libsvn1 libsasl2-modules libcurl4-nss-dev && \
    rm -rf /var/lib/apt/lists/*;

RUN cd /tmp && \
    wget -q repos.mesosphere.com/debian/pool/main/m/mesos/mesos_1.3.1-2.0.1.debian9_amd64.deb && \
    dpkg -i mesos_1.3.1-2.0.1.debian9_amd64.deb && \
    rm mesos_1.3.1-2.0.1.debian9_amd64.deb

# Spark and Mesos config
ENV SPARK_HOME /usr/local/spark
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip
ENV MESOS_NATIVE_LIBRARY /usr/local/lib/libmesos.so
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info

USER $NB_UID

# Install pyarrow
RUN conda install --quiet -y 'pyarrow' && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

USER root
# Install Kerberos & ACL for Saagie
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qq && apt-get install -yqq --no-install-recommends \
      krb5-user acl && \
    rm -rf /var/lib/apt/lists/*;

# Install tools
RUN apt-get update -qq && apt-get install -yqq --no-install-recommends \
      vim nano gnupg2 && \
    rm -rf /var/lib/apt/lists/*;

# Instll freeip client
RUN wget -qO - http://apt.numeezy.fr/numeezy.asc | apt-key add - && \
    echo 'deb http://apt.numeezy.fr stretch main' >> /etc/apt/sources.list && \
    apt-get update -qq && apt-get install -yqq --no-install-recommends \
      freeipa-client && \
    rm -rf /var/lib/apt/lists/*;

RUN apt-get update -qq && apt-get install -yqq --no-install-recommends \
       apt-utils && \
    rm -rf /var/lib/apt/lists/*;

RUN apt-get update -qq && apt-get install -yqq --no-install-recommends \
       libssl-dev && \
    rm -rf /var/lib/apt/lists/*;

#Install hdfs-sentry plugin
#RUN wget https://archive.cloudera.com/cdh5/debian/jessie/amd64/cdh/pool/contrib/s/sentry/sentry-hdfs-plugin_1.5.1+cdh5.13.0+410-1.cdh5.13.0.p0.34~jessie-cdh5.13.0_all.deb &&\
#    dpkg --install sentry*.deb
RUN sudo wget 'https://archive.cloudera.com/cdh5/debian/jessie/amd64/cdh/cloudera.list'  -O /etc/apt/sources.list.d/cloudera.list && \
     apt-get update &&  apt-get install -y --no-install-recommends apt-utils  && \ 
     apt-get install -y  aptitude && aptitude install -y sentry-hdfs-plugin

RUN mkdir -p /usr/lib/impala/lib/ && chown $NB_UID /usr/lib/impala/lib

RUN sed -i '2iln -s /etc/hadoop/conf/sentry-libs/hive-hcatalog-core.jar /usr/lib/impala/lib/hive-hcatalog-core.jar' /usr/local/bin/start-notebook.sh && cat /usr/local/bin/start-notebook.sh

RUN conda install python=3.5.2

WORKDIR /home/jovyan/work

USER $NB_UID
