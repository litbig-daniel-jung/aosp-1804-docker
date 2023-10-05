FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

ENV HOME              /home/android

ARG SDK_VERSION=30.0.2
ARG GRADLE_VERSION=6.5

ENV ANDROID_HOME      /opt/android-sdk-linux
ENV ANDROID_SDK_HOME  ${ANDROID_HOME}
ENV ANDROID_SDK_ROOT  ${ANDROID_HOME}
ENV ANDROID_SDK       ${ANDROID_HOME}
ENV GRADLE_HOME       /opt/gradle/gradle-${GRADLE_VERSION}

ENV PATH "${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin"
ENV PATH "${PATH}:${ANDROID_HOME}/cmdline-tools/tools/bin"
ENV PATH "${PATH}:${ANDROID_HOME}/tools/bin"
ENV PATH "${PATH}:${ANDROID_HOME}/build-tools/${SDK_VERSION}"
ENV PATH "${PATH}:${ANDROID_HOME}/platform-tools"
ENV PATH "${PATH}:${ANDROID_HOME}/emulator"
ENV PATH "${PATH}:${ANDROID_HOME}/bin"
ENV PATH "${PATH}:${GRADLE_HOME}/bin"

# set mirror kakao
RUN sed -i 's@archive.ubuntu.com@mirror.kakao.com@g' /etc/apt/sources.list

RUN dpkg --add-architecture i386 && apt-get update -yqq && \
    apt-get install -y \
        apt-utils \
        expect \
        git \
        git-lfs \
        libc6:i386 \
        libgcc1:i386 \
        libncurses5:i386 \
        libstdc++6:i386 \
        zlib1g:i386 \
        openjdk-8-jdk \
        wget \
        vim \
        git-core \
        gnupg \
        flex \
        bison \
        build-essential \
        zip \
        curl \
        zlib1g-dev \
        libc6-dev-i386 \
        libncurses5 \
        x11proto-core-dev \
        libx11-dev \
        lib32z1-dev \
        libgl1-mesa-dev \
        libxml2-utils \
        xsltproc \
        unzip \
        fontconfig \
        whiptail \
        rsync \
        sudo \
        python \
        python3 \
        python-pip \
        python-dev \
        python-networkx \
        libxml-simple-perl \
        libssl-dev \
        bc \
        liblz4-tool \
        rsync \
        kmod \
        cpio \
        locales \
        bash-completion \
        usbutils \
        minicom
RUN apt-get clean

# RUN adduser --home /home/android android
# RUN usermod -aG sudo android

COPY tools /opt/tools
COPY licenses /opt/licenses

# WORKDIR /opt/android-sdk-linux

RUN /opt/tools/entrypoint.sh built-in

RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "cmdline-tools;latest"
RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "build-tools;${SDK_VERSION}"
RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "platform-tools"
RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "platforms;android-30"
#RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "system-images;android-30;google_apis;x86_64"

# Download gradle, install gradle and gradlew
RUN wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp \
    && unzip -q -d /opt/gradle /tmp/gradle-${GRADLE_VERSION}-bin.zip \
    && mkdir /opt/gradlew \
    && /opt/gradle/gradle-${GRADLE_VERSION}/bin/gradle wrapper --gradle-version ${GRADLE_VERSION} --distribution-type all -p /opt/gradlew  \
    && /opt/gradle/gradle-${GRADLE_VERSION}/bin/gradle wrapper -p /opt/gradlew

# Clean up
RUN rm /tmp/gradle-${GRADLE_VERSION}-bin.zip

RUN chmod -R 777 /opt/tools \
                    /opt/licenses \
                    /opt/android-sdk-linux \
                    /opt/gradlew \
                    /opt/gradle \
                    $HOME

# support special character
RUN locale-gen en_US.UTF-8
RUN echo "root:root" | chpasswd

WORKDIR $HOME

CMD /opt/tools/entrypoint.sh built-in