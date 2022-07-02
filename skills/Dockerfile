ARG TAG=dev
FROM smartgic/mycroft-base:${TAG}

LABEL vendor=Smartgic.io \
    io.smartgic.maintainer="Gaëtan Trellu <gaetan.trellu@smartgic.io>" \
    io.smartgic.image-name="mycroft-skills" \
    io.smartgic.is-beta="no" \
    io.smartgic.is-production="no" \
    io.smartgic.version="${TAG}" \
    io.smartgic.release-date="2021-10-28"

WORKDIR /home/mycroft/core

USER root

RUN apt-get update && \
    apt-get install libffi-dev libssl-dev sudo mpg123 alsa-utils pulseaudio-utils -y && \
    apt-get clean && \
    echo "mycroft ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/010_mycroft-nopasswd && \
    chmod 440 /etc/sudoers.d/010_mycroft-nopasswd && \
    mkdir -p /opt/mycroft/skills && \
    chown mycroft:mycroft -R /opt/mycroft && \
    usermod -a -G audio mycroft && \
    groupadd -g 997 gpio && \
    usermod -a -G gpio mycroft

USER mycroft

RUN ln -s /opt/mycroft/skills /home/mycroft/core/skills && \
    pip install --no-cache-dir -r /home/mycroft/core/requirements/extra-mark1.txt && \
    mkdir -p /home/mycroft/.config/mycroft && \
    rm -rf ~/.cache

ENTRYPOINT ["python", "-m", "mycroft.skills"]
