ARG TAG=dev
FROM smartgic/mycroft-base:${TAG}

LABEL vendor=Smartgic.io \
  io.smartgic.maintainer="Gaëtan Trellu <gaetan.trellu@smartgic.io>" \
  io.smartgic.image-name="mycroft-audio" \
  io.smartgic.is-beta="no" \
  io.smartgic.is-production="no" \
  io.smartgic.version="${TAG}" \
  io.smartgic.release-date="2021-01-01"

WORKDIR /home/mycroft/core

USER root

RUN curl https://forslund.github.io/mycroft-desktop-repo/mycroft-desktop.gpg.key | \
  apt-key add - 2>/dev/null && \
  echo "deb http://forslund.github.io/mycroft-desktop-repo bionic main" \
  > /etc/apt/sources.list.d/mycroft-mimic.list && \
  apt-get update && \
  apt-get install -y alsa-utils mpg123 pulseaudio-utils mimic vlc && \
  apt-get -y autoremove && \
  apt-get clean && \
  usermod -a -G audio mycroft

USER mycroft

RUN mkdir -p /home/mycroft/.config/pulse && \
  pip3 install -r /home/mycroft/core/requirements/extra-audiobackend.txt \
  git+https://github.com/JarbasAl/py_mplayer.git && \
  rm -rf ~/.cache

ENTRYPOINT ["python", "-m", "mycroft.audio"]
