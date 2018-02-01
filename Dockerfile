# Fat image for android + node: FROM beevelop/android-nodejs
FROM thyrlian/android-sdk:latest
LABEL maintainer="Daniel Freiling <ddfreiling@gmail.com>"

ARG NODE_VERSION="8.9.4"
ARG ANDROID_TOOLS_VERSION="27.0.3"
ARG ANDROID_PLATFORM_API="25"
ARG NODE_USER="jenkins"

# Fix source usage
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Dumb-init
RUN wget https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64.deb
RUN dpkg -i dumb-init_*.deb
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Utilities
# RUN apt-get update && \
#     apt-get -y install apt-transport-https unzip curl usbutils --no-install-recommends && \
#     rm -r /var/lib/apt/lists/*

# Android SDK
RUN mkdir -p ~/.android && touch ~/.android/repositories.cfg && \
    echo 'Update platform-tools...' && sdkmanager "platform-tools" && \
    echo 'Update build-tools...'    && sdkmanager "build-tools;$ANDROID_TOOLS_VERSION" && \
    echo 'Update platforms...'      && sdkmanager "platforms;android-$ANDROID_PLATFORM_API" && \
    echo 'Update extras-android...' && sdkmanager "extras;android;m2repository" && \
    echo 'Update extras-google...'  && sdkmanager "extras;google;m2repository" && \
    chmod a+x -R $ANDROID_HOME

# Setup NODE_USER workspace (node/jenkins support)
RUN groupadd --gid 1001 ${NODE_USER} && \
    useradd --uid 1001 --gid ${NODE_USER} --shell /bin/bash --create-home ${NODE_USER}

ENV HOME="/home/${NODE_USER}"
ENV ANDROID_HOME="/opt/android-sdk"
ENV PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"

USER ${NODE_USER}

WORKDIR ${HOME}

# NVM + Node
ENV NVM_DIR="${HOME}/.nvm"
# FIX: gulp-cli/gulp does not work as expected in production mode
#ENV NODE_ENV="production"

RUN wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash -

RUN source $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default && \
    npm i -g nativescript@~3.4.1 --ignore-scripts && \
    tns error-reporting disable && \
    tns usage-reporting disable && \
    npm i -g typescript@~2.5.3 gulp-cli@~1.4.0 && \
    npm cache clean --force

ENV NODE_PATH="$NVM_DIR/v$NODE_VERSION/lib/node_modules"
ENV PATH="$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH"

# NativeScript
# RUN npm i -g nativescript@~3.4.1 --ignore-scripts && \
#     tns error-reporting disable && \
#     tns usage-reporting disable

# Typescript & Gulp
# RUN npm i -g typescript@~2.5.3 gulp-cli@~1.4.0 && \
#     npm cache clean --force

#COPY .npmrc ${HOME}/.npmrc