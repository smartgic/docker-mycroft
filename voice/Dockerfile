ARG TAG=dev
FROM smartgic/mycroft-base:${TAG}

LABEL vendor=Smartgic.io \
    io.smartgic.maintainer="Gaëtan Trellu <gaetan.trellu@smartgic.io>" \
    io.smartgic.image-name="mycroft-voice" \
    io.smartgic.is-beta="no" \
    io.smartgic.is-production="no" \
    io.smartgic.version="${TAG}" \
    io.smartgic.release-date="2021-10-28"

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /home/mycroft/core

USER root

RUN apt-get update && \
    apt-get install -y alsa-utils pulseaudio-utils flac libasound2-plugins libatlas-base-dev gfortran && \
    apt-get -y autoremove && \
    apt-get clean && \
    usermod -a -G audio mycroft

COPY files/client.conf /etc/pulse/client.conf

USER mycroft

COPY files/asoundrc /home/mycroft/.asoundrc

RUN pip3 install --no-cache-dir -r /home/mycroft/core/requirements/extra-stt.txt && \
    pip3 install --no-cache-dir --extra-index-url https://google-coral.github.io/py-repo/ tflite_runtime && \
    pip3 install --no-cache-dir ovos-ww-plugin-precise-lite && \
    mkdir -p /home/mycroft/models && \
    rm -rf ~/.cache

ENTRYPOINT ["python", "-m", "mycroft.client.speech"]
