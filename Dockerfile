FROM java:openjdk-8-jre

ENV DEBIAN_FRONTEND="noninteractive"
ENV ZOOKEEPER_VERSION="3.5.1-alpha"
ENV PATH="$PATH:/opt/zookeeper/bin"

# Expose default Zookeeper port, port for quorum communication,
# and port for leader election
EXPOSE 2181 2888 3888

# Install dnsutils because resolution on AWS doesn't work without it
RUN apt-get update > /dev/null && \
    apt-get install -qq dnsutils && \
    rm -rf /var/lib/apt/lists/* && apt-get clean

# https://github.com/Yelp/dumb-init
RUN curl -fLsS -o /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.0.2/dumb-init_1.0.2_amd64 && chmod +x /usr/local/bin/dumb-init

# https://www.apache.org/mirrors/dist.html
RUN curl -sfL http://archive.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz | tar xzf - -C /opt && \
    mv /opt/zookeeper-${ZOOKEEPER_VERSION} /opt/zookeeper

# Copy over zookeeper config
ADD opt/zookeeper/conf/zoo.cfg /opt/zookeeper/conf/zoo.cfg

# Copy over startup script
ADD usr/local/bin/setupZookeeper.sh /usr/local/bin/setupZookeeper.sh
RUN chmod 755 /usr/local/bin/setupZookeeper.sh

ENTRYPOINT ["/usr/local/bin/dumb-init", "/usr/local/bin/setupZookeeper.sh"]
CMD ["zkServer.sh", "start-foreground"]
