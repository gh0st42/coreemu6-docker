FROM ubuntu:18.04
LABEL Description="Docker image for core network emulator"


ENV DEBIAN_FRONTEND noninteractive

# development tools
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    iputils-ping \
    net-tools \
    vim \
    nano \
    mtr \
    tmux \
    iperf \
    git \
    binutils \
    && apt-get clean

# CORE dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    wget \
    bridge-utils \
    ebtables \
    kmod \
    iproute2 \
    libev4 \
    python3 \
    python3-setuptools \
    python3-pip \
    python3-future \
    python3-tk \
    python3-netaddr \
    python3-mako \
    quagga \
    tcl \
    tk \
    libtk-img \
    lxterminal \
    ethtool \
    psmisc \
    && apt-get clean

#RUN pip3 install \
#grpcio \
#protobuf \
#lxml \
#fabric

# install ssh deamon
RUN apt-get update \
    && apt-get install -y --no-install-recommends ssh \
    && apt-get clean

# CORE
RUN wget --quiet https://github.com/coreemu/core/releases/download/release-6.4.0/core_6.4.0_amd64.deb \
    && dpkg -i core_6.4.0_amd64.deb \
    && rm core_6.4.0_amd64.deb

WORKDIR /root
RUN wget https://raw.githubusercontent.com/coreemu/core/master/daemon/requirements.txt && \
    python3 -m pip install -r requirements.txt && \
    rm requirements.txt

# various last minute deps

WORKDIR /root
RUN git clone https://github.com/gh0st42/core-helpers &&\
    cd core-helpers && ./install-symlinks.sh

# enable sshd
RUN mkdir /var/run/sshd &&  sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#X11UseLocalhost yes/X11UseLocalhost no/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV PASSWORD "netsim"
RUN echo "root:$PASSWORD" | chpasswd

ENV SSHKEY ""

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22

# ADD extra /extra
VOLUME /shared

COPY entryPoint.sh /root/entryPoint.sh
ENTRYPOINT "/root/entryPoint.sh"

