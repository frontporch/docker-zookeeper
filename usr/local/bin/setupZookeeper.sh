#! /bin/bash -e
ZOOKEEPER_CONFIG="/opt/zookeeper/conf/zoo.cfg"

# Set the Zookeeper ID for this container based off the id passed into the container
ZOOKEEPER_ID="${ZOOKEEPER_ID:-1}"
echo $ZOOKEEPER_ID > /opt/zookeeper/conf/myid

# Set the config based on environment variables

# the location where ZooKeeper will store the in-memory database snapshots and, unless specified otherwise, the
# transaction log of updates to the database.
DATA_DIR="${DATA_DIR:-/var/lib/zookeeper}"
echo "dataDir: $DATA_DIR"
sed -r -i "s|(dataDir)=(.*)|\1=$DATA_DIR|g" $ZOOKEEPER_CONFIG

# This option will direct the machine to write the transaction log to the dataLogDir rather than the dataDir. This
# allows a dedicated log device to be used, and helps avoid competition between logging and snaphots.
# Having a dedicated log device has a large impact on throughput and stable latencies. It is highly recommened
# to dedicate a log device and set dataLogDir to point to a directory on that device, and then make sure to point
# dataDir to a directory not residing on that device.
DATA_LOG_DIR="${DATA_LOG_DIR:-/var/lib/zookeeper}"
echo "dataDir: $DATA_LOG_DIR"
sed -r -i "s|(dataLogDir)=(.*)|\1=$DATA_LOG_DIR|g" $ZOOKEEPER_CONFIG

# Space delimited array of Zookeeper Servers in cluster, Zookeeper defaults to a single server cluster at
# localhost if not provided.
# Example:
#   ZOOKEEPER_SERVERS="172.31.0.2:2888:3888 172.31.0.3:2888:3888 172.31.0.4:2888:3888"
if [ -n "$ZOOKEEPER_SERVERS" ]; then

    # Remove any existing config for the servers before appending
    sed -r -i "/(server\.)[0-9]+=(.*)/d" $ZOOKEEPER_CONFIG

    ARRAY_OF_SERVERS=($ZOOKEEPER_SERVERS)
    SERVER_COUNT=1
    for SERVER in "${ARRAY_OF_SERVERS[@]}"
    do
        SERVER_VALUE="server.${SERVER_COUNT}=${SERVER}"
        echo "server.${SERVER_COUNT}: ${SERVER_VALUE}"
        # append these to the end of the config
        echo "$SERVER_VALUE" >> $ZOOKEEPER_CONFIG
        ((SERVER_COUNT++))
    done
fi

# Do what
exec "$@"
