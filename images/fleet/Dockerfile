FROM golang

RUN apt-get -y update
RUN apt-get -y install ssh

WORKDIR /root

RUN git clone https://github.com/coreos/fleet.git
RUN cd fleet && ./build
