FROM ubuntu:xenial
MAINTAINER Nick Weedon <nick@weedon.org.au>

# The timezone for the image (set to Etc/UTC for UTC)
ARG IMAGE_TZ=America/New_York

USER root

# Add locales after locale-gen as needed
# Upgrade packages on image
# Preparations for sshd
run locale-gen en_US.UTF-8 &&\
    apt-get -q update &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q upgrade -y -o Dpkg::Options::="--force-confnew" --no-install-recommends &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew"  --no-install-recommends openssh-server &&\
    apt-get -q autoremove &&\
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin &&\
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd &&\
    mkdir -p /var/run/sshd

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Set the timezone
# Normally this would be done via: echo ${IMAGE_TZ} >/etc/timezone && dpkg-reconfigure -f noninteractive tzdata 
# A bug in the current version of Ubuntu prevents this from working: https://bugs.launchpad.net/ubuntu/+source/tzdata/+bug/1554806
# Change this to the normal method once this is fixed.
RUN ln -fs /usr/share/zoneinfo/${IMAGE_TZ} /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

# Install Oracle Java 8
RUN \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/webupd8team-java.list && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    apt-get update && \
    apt-get install -y oracle-java8-installer --no-install-recommends && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle


RUN apt-get clean && apt-get update && apt-get install -y --no-install-recommends \
    bzip2 \
    nodejs \
    nodejs-legacy \
    npm \
    maven \
    git \
    ruby \
    software-properties-common \
    libfontconfig1 \
    libfontconfig1-dev \
    libfreetype6 \
    libfreetype6-dev \
    curl \
    unzip \
    xml2 && \
    apt-get -q autoremove && \
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

RUN npm install -g \
    bower \
    grunt \
    less

COPY sencha/install-5.1.3.61.sh /tmp

########################## Install Sencha CMD #####################################
ENV PATH="${PATH}:/opt/Sencha/Cmd/5.1.3.61"

# Install Sencha CMD and also pull down ext then delete it, forcing it to be cached
# This means that the ext framework will still be available to us on an old image even when it 
# no longer exists on the internet.
RUN cd /tmp && \
    ./install-5.1.3.61.sh && \
    sencha package repo init -name "Nick Weedon" -email "nick@weedon.org.au" && \
    sencha package extract -todir=. ext@5.0.1.1255 && \
    chmod -R o+rw /opt/Sencha/Cmd/repo && \
    rm -r ext

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


