ARG TAG=dev
FROM smartgic/mycroft-base:${TAG}

LABEL vendor=Smartgic.io \
  io.smartgic.maintainer="Gaëtan Trellu <gaetan.trellu@smartgic.io>" \
  io.smartgic.image-name="mycroft-audio" \
  io.smartgic.is-beta="no" \
  io.smartgic.is-production="no" \
  io.smartgic.version="${TAG}" \
  io.smartgic.release-date="2022-09-22"

WORKDIR /home/mycroft/core

USER root

RUN curl https://forslund.github.io/mycroft-desktop-repo/mycroft-desktop.gpg.key | \
  apt-key add - 2>/dev/null && \
  echo "deb http://forslund.github.io/mycroft-desktop-repo bionic main" \
  > /etc/apt/sources.list.d/mycroft-mimic.list && \
  apt-get update && \
  apt-get install -y alsa-utils libasound2-plugins mpg123 pulseaudio-utils mimic vlc libespeak-ng1 && \
  apt-get -y autoremove && \
  apt-get clean && \
  usermod -a -G audio mycroft && \
  mkdir -p /opt/mycroft/{preloaded_cache,voices} && \
  chown mycroft:mycroft -R /opt/mycroft

USER mycroft

COPY files/asoundrc /home/mycroft/.asoundrc

ARG TARGETPLATFORM

RUN if [ "${TARGETPLATFORM}" = "linux/arm/v7" ]; then pip3 install -f 'https://synesthesiam.github.io/prebuilt-apps/' onnxruntime; fi

RUN mkdir -p /home/mycroft/.config/pulse && \
  mkdir -p /home/mycroft/.local/share/mycroft/mimic3/voices && \
  pip3 install --no-cache-dir -r /home/mycroft/core/requirements/extra-audiobackend.txt boto3==1.24.74 \
  mycroft-plugin-tts-mimic3[all] && \
  rm -rf ~/.cache

ENTRYPOINT ["python", "-m", "mycroft.audio"]
