FROM debian:buster-slim

ARG TAG=dev

LABEL vendor=Smartgic.io \
  io.smartgic.maintainer="Gaëtan Trellu <gaetan.trellu@smartgic.io>" \
  io.smartgic.image-name="mycroft-base" \
  io.smartgic.is-beta="no" \
  io.smartgic.is-production="no" \
  io.smartgic.version="${TAG}" \
  io.smartgic.release-date="2021-10-28"

ENV TERM linux
ENV DEBIAN_FRONTEND noninteractive
ENV VIRTUAL_ENV /opt/mycroft-venv
ENV MYCROFT_DIR /home/mycroft/core

ARG BRANCH
ARG PYTHON_VERSION="python3 -c 'from sys import version_info as i; print(f\"{i[0]}.{i[1]}\")'"

RUN apt-get update && \
  apt-get install -y git python3 python3-venv python3-dev curl swig libffi-dev \
  portaudio19-dev zlib1g-dev libjpeg-dev libfann-dev build-essential && \
  c_rehash && \
  apt-get autoremove -y && \
  apt-get clean && \
  useradd --no-log-init mycroft -m && \
  python3 -m venv $VIRTUAL_ENV && \
  chown mycroft:mycroft -R $VIRTUAL_ENV

USER mycroft

ENV PATH ${VIRTUAL_ENV}/bin/:$PATH

RUN git clone https://github.com/MycroftAI/mycroft-core.git \
  $MYCROFT_DIR -b $BRANCH && \
  pip3 install --no-cache-dir -U pip && \
  pip3 install --no-cache-dir wheel numpy && \
  pip3 install --no-cache-dir -r ${MYCROFT_DIR}/requirements/requirements.txt && \
  echo "${MYCROFT_DIR}" > ${VIRTUAL_ENV}/lib/python$(eval ${PYTHON_VERSION})/site-packages/mycroft.pth && \
  rm -rf ${HOME}/.cache && \
  mkdir -p /tmp/mycroft/ipc /home/mycroft/.config/mycroft /home/mycroft/.cache/mycroft /tmp/mycroft/cache
