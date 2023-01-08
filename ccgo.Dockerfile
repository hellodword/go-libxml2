FROM ubuntu:jammy

ARG goversion="1.18.9"

RUN apt-get update && \
    apt-get install -y \
        build-essential gcc make \
        autoconf pkgconf \
        python3 python3-dev \
        libtool \
        git ca-certificates curl \
        strace \
        libpthread-stubs0-dev

RUN git clone -b v2.10.3 --depth=1 https://gitlab.gnome.org/GNOME/libxml2.git && \
    cd libxml2 && \
    ./autogen.sh

RUN cd / && curl -O "https://dl.google.com/go/go${goversion}.linux-amd64.tar.gz" && \
    tar -xzf "go${goversion}.linux-amd64.tar.gz"

ENV PATH=/go/bin:$PATH
ENV PATH=/root/go/bin:$PATH
ENV GO111MODULE=on

RUN cd libxml2 && \
    go mod init libxml2 && \
    go get modernc.org/libc && \
    go install -x -v modernc.org/ccgo/v3@master && \
    ccgo -compiledb libxml2.json make && \
    CC=/usr/bin/gcc ccgo \
        -o libxml2_linux_amd64.go \
        -pkgname lib \
        -trace-translation-units \
        libxml2.json \
        ./.libs/libxml2.so.2.10.3
        # error

