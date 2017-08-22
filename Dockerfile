FROM debian:stretch

RUN apt-get update && apt-get install -y \
    locales \
    make \
    wget \
    gcc g++ \
    autoconf automake \
    flex bison \
    git \
    unzip bzip2 \
    libtool libtool-bin \
    gperf \
    texinfo help2man \
    gawk sed \
    ncurses-dev \ 
    libexpat-dev \
    python python-dev python-serial

# Setup locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

# Create user
RUN useradd -m builder
USER builder
WORKDIR /home/builder

# Install ESP8266 SDK
RUN git clone --recursive https://github.com/pfalcon/esp-open-sdk.git /home/builder/esp-open-sdk \
    && cd /home/builder/esp-open-sdk \
    git reset --hard e8d757b1a70a5cf19df0afe23a769739c6cff343
RUN cd /home/builder/esp-open-sdk; make VENDOR_SDK=1.5.4 STANDALONE=y

ENV PATH /home/builder/esp-open-sdk/xtensa-lx106-elf/bin:$PATH
ENV XTENSA_TOOLS_ROOT /home/builder/esp-open-sdk/xtensa-lx106-elf/bin
ENV SDK_BASE /home/builder/esp-open-sdk/sdk
ENV FW_TOOL /home/builder/esp-open-sdk/xtensa-lx106-elf/bin/esptool.py  
ENV ESP_HOME /home/builder/esp-open-sdk
ENV SMING_HOME /home/builder/Sming/Sming

# Install esptool
RUN git clone --recursive https://github.com/themadinventor/esptool.git /home/builder/esptool \
    && cd /home/builder/esptool \
    && git reset --hard c1d00094d564451636b01308625119901e2257ac

ENV PATH /home/builder/esptool:$PATH

# Install esptool2
RUN git clone --recursive https://github.com/raburton/esptool2 /home/builder/esptool2 \
    && cd /home/builder/esptool2 \
    && git reset --hard ec0e2c72952f4fa8242eedd307c58a479d845abe
RUN cd /home/builder/esptool2; make

ENV PATH /home/builder/esptool2:$PATH

# Install sming
RUN git clone https://github.com/SmingHub/Sming.git /home/builder/Sming \
    && cd /home/builder/Sming \
    && git reset --hard bc0a8d3ec42c8847f3807ad6a90e44b3a85511b7
RUN cd /home/builder/Sming/Sming; make clean; make

USER root
