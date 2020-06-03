#!/bin/sh

xhost + 127.0.0.1

docker run -it --rm \
    --name coreemu6 \
    -p 2000:22 \
    -v shared:/shared \
    --cap-add=NET_ADMIN \
    --cap-add=SYS_ADMIN \
    -e SSHKEY="`cat ~/.ssh/id_rsa.pub`" \
    -e DISPLAY=host.docker.internal:0 \
    --privileged \
    gh0st42/coreemu6
