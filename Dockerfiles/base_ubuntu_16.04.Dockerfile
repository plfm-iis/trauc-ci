FROM ubuntu:16.04

ARG Z3_SRC_DIR
ARG Z3_BUILD_DIR
ARG BENCHMARK_REPO="https://github.com/guluchen/z3.git"
ARG BENCHMARK_PATH="/benchmarks"

ENV \
    Z3_SRC_DIR=${Z3_SRC_DIR} \
    Z3_BUILD_DIR=${Z3_BUILD_DIR} \
    BENCHMARK_REPO=${BENCHMARK_REPO} \
    BENCHMARK_PATH=${BENCHMARK_PATH}

RUN apt-get update && \
    apt-get install build-essential software-properties-common -y && \
    add-apt-repository ppa:ubuntu-toolchain-r/test && \
    apt-get update && \
    apt-get install -y -f gcc-6 g++-6 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 60 --slave /usr/bin/g++ g++ /usr/bin/g++-6 && \
    apt-get -y --no-install-recommends install \
	binutils \
	cmake \
	doxygen \
	default-jdk \
	gcc-multilib \
	git \
	wget \
	tar \
	graphviz \
	g++-multilib \
	libgmp-dev \
	libgomp1 \
	libomp5 \
	libomp-dev \
	llvm \
	m4 \
	ppl-dev \
	libmpfr-dev \
	make \
	mono-devel \
	uuid-dev \
    unzip \
	sudo

RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3.6 python3-pip

RUN pip3 install argparse typing

# Create `user` user for container with password `user`.  and give it
# password-less sudo access
RUN useradd -m user && \
    echo user:user | chpasswd && \
    cp /etc/sudoers /etc/sudoers.bak && \
    echo 'user  ALL=(root) NOPASSWD: ALL' >> /etc/sudoers
USER user
WORKDIR /home/user
ENV HOME="/home/user"


# Install Openfst and Apron
RUN \
    wget http://www.openfst.org/twiki/pub/FST/FstDownload/openfst-1.7.1.tar.gz && \
    tar zxvf openfst-1.7.1.tar.gz && \
    cd openfst-1.7.1 && \
    ./configure && \
    make && \
    sudo make install

RUN \
    git clone https://github.com/antoinemine/apron.git && \
    cd apron && \
    ./configure && \
    make && \
    sudo make install

# Clean up $HOME
RUN rm -rf /home/user/* 

RUN mkdir -p ${Z3_SRC_DIR} && \
    mkdir -p ${Z3_BUILD_DIR} && \
    mkdir -p ${BENCHMARK_PATH}

