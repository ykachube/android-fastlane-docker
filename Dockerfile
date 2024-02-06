FROM eclipse-temurin:17-jdk-jammy

LABEL maintainer "yury.kachubeyeu@gmail.com"

ENV NODE_VERSION 18.17.0
ENV ANDROID_SDK_URL https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip
ENV ANDROID_API_LEVEL android-34
ENV ANDROID_BUILD_TOOLS_VERSION 34.0.0
ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV ANDROID_VERSION 34
ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/bin

RUN apt-get update && \
apt-get install --no-install-recommends -y --allow-unauthenticated xz-utils gpg-agent unzip build-essential git gpg dirmngr

RUN mkdir "$ANDROID_HOME" .android && \
    cd "$ANDROID_HOME" && \
    curl -o sdk.zip $ANDROID_SDK_URL && \
    unzip sdk.zip && \
    rm sdk.zip && \
# Download Android SDK
yes | sdkmanager --licenses --sdk_root=$ANDROID_HOME && \
sdkmanager --update --sdk_root=$ANDROID_HOME && \
sdkmanager --sdk_root=$ANDROID_HOME "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
    "platforms;android-${ANDROID_VERSION}" \
    "platform-tools" \
    "extras;android;m2repository" \
    "extras;google;m2repository" && \
# Install Fastlane
apt-get install --no-install-recommends -y --allow-unauthenticated  ruby-full && \
gem install rake && \
gem install fastlane && \
gem install bundler && \
# Clean up
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
apt-get autoremove -y && \
apt-get clean
################################################################################################
###
### Install NodeJS & NPM
###

RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  ; do \
    gpg --keyserver  keyserver.ubuntu.com --recv-keys "$key"; \
  done


RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.xz"  \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs



# Remove Build Deps
RUN apt-get purge -y --auto-remove $buildDeps

# Output versions
RUN node -v && npm -v && ruby -v && bundler -v
