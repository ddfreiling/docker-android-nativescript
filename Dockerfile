# Fat image for android + node: FROM beevelop/android-nodejs
FROM thyrlian/android-sdk:latest
MAINTAINER Daniel Freiling <ddfreiling@gmail.com>

ARG NODE_MAJOR_VERSION="8"
ARG ANDROID_TOOLS_VERSION="27.0.3"
ARG ANDROID_PLATFORM_API="25"

# Utilities
RUN apt-get update && \
    apt-get -y install apt-utils apt-transport-https unzip curl usbutils --no-install-recommends && \
    rm -r /var/lib/apt/lists/*
    
# Update Android SDK
RUN mkdir -p ~/.android && touch ~/.android/repositories.cfg && \
    echo 'Update platform-tools...' && sdkmanager "platform-tools" && \
    echo 'Update build-tools...'    && sdkmanager "build-tools;$ANDROID_TOOLS_VERSION" && \
    echo 'Update platforms...'      && sdkmanager "platforms;android-$ANDROID_PLATFORM_API" && \
    echo 'Update extras-android...' && sdkmanager "extras;android;m2repository" && \
    echo 'Update extras-google...'  && sdkmanager "extras;google;m2repository" && \
    chmod a+x -R $ANDROID_HOME && \
    chown -R root:root $ANDROID_HOME

# NodeJS
RUN curl -sL https://deb.nodesource.com/setup_$NODE_MAJOR_VERSION.x | bash - && \
    apt-get update && \
    apt-get -y install nodejs --no-install-recommends && \
    rm -r /var/lib/apt/lists/*

# NativeScript
RUN npm i -g nativescript@^3.4.1 --ignore-scripts --production && \
    tns error-reporting disable && \
    tns usage-reporting disable

# Typescript & Gulp
RUN npm i -g typescript gulp-cli --production && \
    npm cache clean --force