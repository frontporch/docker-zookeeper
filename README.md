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

## Zookeeper ID
I was seeing some errors on Kubernetes when running Zookeeper, it may have just been the
Kubernetes DNS, but it was something like the following:
```
2016-07-19 18:46:40,660 [myid:1] - INFO  [zookeeper-1/X.X.X.X:3888:QuorumCnxManager$Listener@631] - My election bind port: zookeeper-1/X.X.X.X:3888
2016-07-19 18:46:40,661 [myid:1] - ERROR [zookeeper-1/X.X.X.X:3888:QuorumCnxManager$Listener@646] - Exception while listening
java.net.BindException: Cannot assign requested address
        at java.net.PlainSocketImpl.socketBind(Native Method)
        at java.net.AbstractPlainSocketImpl.bind(AbstractPlainSocketImpl.java:387)
        at java.net.ServerSocket.bind(ServerSocket.java:375)
        at java.net.ServerSocket.bind(ServerSocket.java:329)
        at org.apache.zookeeper.server.quorum.QuorumCnxManager$Listener.run(QuorumCnxManager.java:633)
2016-07-19 18:46:41,661 [myid:1] - INFO  [zookeeper-1/X.X.X.X:3888:QuorumCnxManager$Listener@659] - Leaving listener
2016-07-19 18:46:41,661 [myid:1] - ERROR [zookeeper-1/X.X.X.X:3888:QuorumCnxManager$Listener@661] - As I'm leaving the listener thread, I won't be able to participate in leader election any longer: zookeeper-1/X.X.X.X:3888
```
There's some insight on StackOverflow [here](http://stackoverflow.com/questions/30940981/zookeeper-error-cannot-open-channel-to-x-at-election-address) and
[here](http://stackoverflow.com/questions/29323311/zookeeper-installation-on-multiple-aws-ec2instances) and both suggest replacing the address of the current
server in it's Zookeeper config with localhost.  We do exactly that when generating the config by looking for the server with the ID specified in the `MYID`
file and then changing that IP address to localhost only within it's config.

