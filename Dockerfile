FROM docker.artifactory.weedon.org.au/redwyvern/ubuntu-base:xenial
MAINTAINER Nick Weedon <nick@weedon.org.au>

######################### C++ Dev Env Pre-Reqs #################################
RUN apt-get clean && apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    g++ python-dev \
    autotools-dev \
    libicu-dev \
    build-essential \
    libbz2-dev \
    gcovr \
    cppcheck \
    doxygen \
    graphviz && \
    apt-get -q autoremove && \
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

############### Compile and install "latest" version of CMake ##################

RUN cd /tmp && \
    wget https://cmake.org/files/v3.6/cmake-3.6.1.tar.gz && \
    tar -xzvpsf cmake-3.6.1.tar.gz && \
    cd /tmp/cmake-3.6.1 && \
    ./configure && \
    make -j 4 && \
    make install && \
    rm -r /tmp/cmake-3.6.1

################################## Install GCC 6.x ##############################

RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    apt-get clean && apt-get update && apt-get install -y --no-install-recommends \
    gcc-6 \
    g++-6 && \
    apt-get -q autoremove && \
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin


############### Compile (with GCC 6.x) and install "latest" version of Boost ##################
            
RUN cd /opt && wget https://sourceforge.net/projects/boost/files/boost/1.60.0/boost_1_60_0.tar.gz && \
    tar -xzvpsf boost_1_60_0.tar.gz && \
    cd boost_1_60_0 && \
    ./bootstrap.sh && \
    echo "using gcc : 6 : /usr/bin/g++-6 ; " >> tools/build/src/user-config.jam && \
    export MAKEFLAGS="-j 4" && \
    ./bjam  install \
            -j 4 \
            threading=multi \
            --build-type=complete \
            --layout=versioned \
            --without-mpi \
            --toolset=gcc-6 \
            --prefix=/opt/boost && \
    cd - && rm boost_1_60_0.tar.gz && rm -r boost_1_60_0


