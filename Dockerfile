FROM java:openjdk-8-jre

ENV DEBIAN_FRONTEND="noninteractive"
ENV ZOOKEEPER_VERSION="3.4.5+dfsg-2"
ENV PATH="$PATH:/usr/share/zookeeper/bin"

# Install Zookeeper and dependencies
RUN apt-get update > /dev/null && \
    apt-get install -qq supervisor dnsutils && \
    apt-get install -qq zookeeper=$ZOOKEEPER_VERSION && \
    rm -rf /var/lib/apt/lists/* && apt-get clean

# Copy over zookeeper config
ADD etc/zookeeper/conf/zoo.cfg /etc/zookeeper/conf/zoo.cfg

# Copy over supervisor config
ADD supervisor/zookeeper.conf /etc/supervisor/conf.d/

# Copy over startup script
ADD usr/local/bin/startZookeeper.sh /usr/local/bin/startZookeeper.sh

# Expose default Zookeeper port, port for quorum communication,
# and port for leader election
EXPOSE 2181 2888 3888

#CMD ["supervisord", "-n"]
CMD ["/usr/local/bin/startZookeeper.sh"]
