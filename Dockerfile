FROM ubuntu:14.04

# hopefully temporary work-around of http://git.io/Ke_Meg#1724 
RUN apt-mark hold initscripts udev plymouth mountall

ENV HOME /root
RUN mkdir /build
ADD . /build

RUN chmod +x /build/prepare.sh
RUN /build/prepare.sh

# Add package sources
# Install dependencies for mastercore (mscore-0.0.8/doc/build-unix.md)
RUN apt-get update
RUN apt-get install software-properties-common
RUN add-apt-repository ppa:bitcoin/bitcoin
RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN apt-get update
RUN apt-get install \
    install pkg-config \
    git \
    scons \
    ctags \
    libboost1.55-all-dev \
    protobuf-compiler \
    libprotobuf-dev \
    libssl-dev \
    gcc-4.9 \
    g++-4.9

# Upgrade to gcc-4.9 (after some other package pulls in gcc)
#RUN rm -f /usr/bin/gcc && ln -s /usr/bin/gcc-4.9 /usr/bin/gcc
#RUN rm -f /usr/bin/g++ && ln -s /usr/bin/g++-4.9 /usr/bin/g++

# Checkout the ripple source
RUN git clone https://github.com/ripple/rippled.git /opt/rippled -b develop
RUN cd /opt/rippled && scons build/rippled

# peer_port
EXPOSE 51235
# websocket_public_port
EXPOSE 5006
# websocket_port (trusted access)
EXPOSE 6006

# Share the ripple data directory
VOLUME /var/lib/rippled

RUN mkdir /opt/rippled/build/db

# Add custom config
ADD rippled.cfg /opt/rippled/build/rippled.cfg

CMD ["/opt/rippled/build/rippled", "--net", "--conf", "/opt/rippled/build/rippled.cfg"]
