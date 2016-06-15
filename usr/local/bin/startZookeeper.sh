#! /bin/bash -e

ZOOKEEPER_CONFIG="/etc/zookeeper/conf/zoo.cfg"

# Set the Zookeeper ID for this container based off the last octet of the IP Address
echo $(( $(awk 'NR==7 {print $1}' /etc/hosts | cut -d "." -f 4) - 1)) > /etc/zookeeper/conf/myid

# Set the config based on environment variables
if [ ! -z "$TICK_TIME" ]; then
    echo "tickTime: $TICK_TIME"
    sed -r -i "s/(tickTime)=(.*)/\1=$TICK_TIME/g" $ZOOKEEPER_CONFIG
fi
if [ ! -z "$INIT_LIMIT" ]; then
    echo "initLimit: $INIT_LIMIT"
    sed -r -i "s/(initLimit)=(.*)/\1=$INIT_LIMIT/g" $ZOOKEEPER_CONFIG
fi
if [ ! -z "$SYNC_LIMIT" ]; then
    echo "syncLimit: $SYNC_LIMIT"
    sed -r -i "s/(syncLimit)=(.*)/\1=$SYNC_LIMIT/g" $ZOOKEEPER_CONFIG
fi
if [ ! -z "$CLIENT_PORT" ]; then
    echo "clientPort: $CLIENT_PORT"
    sed -r -i "s/(clientPort)=(.*)/\1=$CLIENT_PORT/g" $ZOOKEEPER_CONFIG
fi

# set default value if none is provided
if [ -z "$ZOOKEEPER_SERVERS" ]; then
    ### example value of what is expected and at least one is needed
    # ZOOKEEPER_SERVERS="172.31.0.2:2888:3888 172.31.0.3:2888:3888 172.31.0.4:2888:3888"
    ZOOKEEPER_SERVERS="127.0.0.1:2888:3888"
fi
# remove any existing config for the servers before appending
sed -r -i "/(server\.)[0-9]+=(.*)/d" $ZOOKEEPER_CONFIG

ARRAY_OF_SERVERS=($ZOOKEEPER_SERVERS)
SERVER_COUNT=1
for server in "${ARRAY_OF_SERVERS[@]}"
do
    SERVER_VALUE="server.${SERVER_COUNT}=${server}"
    echo "server.${SERVER_COUNT}: $SERVER_VALUE"
    # append these to the end of the config
    echo "$SERVER_VALUE" >> $ZOOKEEPER_CONFIG
    ((SERVER_COUNT++))
done

# Start Zookeeper
supervisord -n
