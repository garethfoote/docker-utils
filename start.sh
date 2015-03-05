#!/bin/bash
DB_PASSWORD=password
CONTAINER_NAME=web
VERSION=":v5"
STATIC_IP=false
source .env

while [[ $# -ge 1 ]]
do
key="$1"

case $key in
    -p|--password)
    DB_PASSWORD="$2"
    shift
    ;;
    -c|--name)
    CONTAINER_NAME="$2"
    shift
    ;;
    -V|--version)
    VERSION="$2"
    shift
    ;;
    -s|--static)
    STATIC_IP=true
    shift
    ;;
    --default)
    DEFAULT=YES
    shift
    ;;
    *)
            # unknown option
    ;;
esac
shift
done

docker kill $CONTAINER_NAME
docker rm $CONTAINER_NAME

setStaticIp () {
    # http://stackoverflow.com/questions/25529386/how-can-i-set-a-static-ip-address-in-a-docker-container
    mkdir -p /var/run/netns
    ln -s /proc/$1/ns/net /var/run/netns/$1

    ip link add A type veth peer name B
    brctl addif docker0 A
    ip link set A up

    ip link set B netns $1
    ip netns exec $1 ip link set dev B name eth0
    ip netns exec $1 ip link set eth0 up
    ip netns exec $1 ip addr add 172.17.42.99/16 dev eth0
    ip netns exec $1 ip route add default via 172.17.42.1
}


if  ! $STATIC_IP; then
    # 1. Original.
    docker run --name $CONTAINER_NAME -v $(pwd)/../web/:/app -p 8080:80 -p 22 -e MYSQL_PASS="$DB_PASSWORD" garethfoote/lamp${VERSION}
else
    echo "Setting static ip manually."; 
    echo "Creates new network interfaces so might mess with WiFi icon in Ubuntu."
    # 2. No networking set up. Manually done below.
    docker run --name $CONTAINER_NAME -v $(pwd)/../web/:/app -p 8080:80 -p 22 -e MYSQL_PASS="$DB_PASSWORD" -d -t --net=none garethfoote/lamp${VERSION}

    pid=$(docker inspect -f '{{.State.Pid}}' dcreform)
    echo $pid > pid.log

    setStaticIp $pid
fi

# 3. As above but With interactive shell.
# docker run --name $CONTAINER_NAME -v $(pwd)/../web/:/app -p 8080:80 -p 22 -e MYSQL_PASS="$DB_PASSWORD" -i -t --net=none garethfoote/lamp${VERSION} /bin/bash
