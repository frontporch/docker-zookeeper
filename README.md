# Zookeeper

A Zookeeper container for Docker.

## Acknowledgements

We originally needed to run Zookeeper as a dependency for Apache Kafka.  We started out with the
all-in-one container [spotify/docker-kafka](https://github.com/spotify/docker-kafka), which contained
a single instance of both Zookeeper and Kafka in a container.  However, once we got up and running we
needed to separate Kafka and Zookeeper and run multiple instances of each as clusters.
Initially, we just teased apart the Spotify container into separate containers, but it was using
`systemd` to manage the Zookeeper and Kafka processes and once teased apart, `systemd` didn't
really lend itself well to running under Docker (see below).  So we migrated to the technique used
in [mesoscloud/zookeeper](https://github.com/mesoscloud/zookeeper) instead.  We maintained the same
Apache license included with the mesoscloud/zookeeper container.

## Startup & Shutdown Behavior
We encountered some issues with Zookeeper startup/shutdown behaviour.  Originally, we were using
`systemd` to run Zookeeper, but it wasn't designed with Docker in mind, so we migrated to
[dumb-init](https://github.com/Yelp/dumb-init) as a ligthweight process manager.  We also
bumped Zookeeper to version 3.4.8 because of shutdown
[deadlock](https://issues.apache.org/jira/browse/ZOOKEEPER-2347) possibly preventing a container
from restarting cleanly.
