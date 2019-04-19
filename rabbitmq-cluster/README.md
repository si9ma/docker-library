# rabbitmq-cluster

docker rabbitmq cluster (clone from https://github.com/bijukunjummen/docker-rabbitmq-cluster), use haproxy providing load balancing

* if needed, additional nodes can be added to this file. If the entire cluster comes up, the management console can be accessed at http://dockerip:15672
* access rabbitmq at dockerip:5672
* access haproxy stats at http://dockerip:1936