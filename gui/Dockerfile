FROM debian:bullseye-slim

ARG TAG=master

LABEL vendor=Smartgic.io \
  io.smartgic.maintainer="Gaëtan Trellu <gaetan.trellu@smartgic.io>" \
  io.smartgic.image-name="mycroft-gui" \
  io.smartgic.is-beta="no" \
  io.smartgic.is-production="no" \
  io.smartgic.version="${TAG}" \
  io.smartgic.release-date="2021-12-01"

ENV TERM linux
ENV DEBIAN_FRONTEND noninteractive
ENV MYCROFT_DIR /opt/myroft

ARG BRANCH

RUN apt-get update && \
  apt-get install -y git-core g++ cmake extra-cmake-modules gettext pkg-config \
  qml-module-qtwebengine pkg-kde-tools qtbase5-dev qtdeclarative5-dev libkf5kio-dev \
  libqt5websockets5-dev libkf5i18n-dev libkf5notifications-dev libkf5plasma-dev \
  libqt5webview5-dev qtmultimedia5-dev kirigami2-dev qml-module-qtmultimedia mesa-utils && \
  apt-get autoremove -y && \
  apt-get clean && \
  useradd --no-log-init mycroft -m && \
  groupdel kvm && \
  groupdel render

RUN git clone https://github.com/MycroftAI/mycroft-gui.git \
  ${MYCROFT_DIR}/gui -b $BRANCH && \
  mkdir -p ${MYCROFT_DIR}/gui/build-testing && \
  cd ${MYCROFT_DIR}/gui/build-testing && \
  cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DKDE_INSTALL_LIBDIR=lib -DKDE_INSTALL_USE_QT_SYS_PATHS=ON && \
  make -j $(nproc) && \
  make install

RUN git clone https://github.com/kbroulik/lottie-qml.git \
  ${MYCROFT_DIR}/lottie-qml && \
  mkdir -p ${MYCROFT_DIR}/lottie-qml/build-testing && \
  cd ${MYCROFT_DIR}/lottie-qml/build-testing && \
  cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DKDE_INSTALL_LIBDIR=lib -DKDE_INSTALL_USE_QT_SYS_PATHS=ON && \
  make -j $(nproc) && \
  make install && \
  rm -rf $MYCROFT_DIR

RUN mkdir -p /etc/mycroft && \
    chown mycroft:mycroft /etc/mycroft/

USER mycroft

COPY files/mycroft.conf /etc/mycroft/mycroft.conf

ENTRYPOINT ["mycroft-gui-app"]