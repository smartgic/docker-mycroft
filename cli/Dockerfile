ARG TAG=dev
FROM smartgic/mycroft-base:${TAG}

LABEL vendor=Smartgic.io \
    io.smartgic.maintainer="Gaëtan Trellu <gaetan.trellu@smartgic.io>" \
    io.smartgic.image-name="mycroft-cli" \
    io.smartgic.is-beta="no" \
    io.smartgic.is-production="no" \
    io.smartgic.version="${TAG}" \
    io.smartgic.release-date="2021-10-28"

WORKDIR /home/mycroft/core

ENV PATH $VIRTUAL_ENV/bin/:$PATH:/home/mycroft/core/bin
ENV EDITOR vim

USER root

RUN apt-get update && \
    apt-get install jq vim -y && \
    mkdir -p /opt/mycroft && \
    chown mycroft:mycroft /opt/mycroft

USER mycroft

RUN mkdir -p /home/mycroft/core/.venv/bin && \
    ln -s ${VIRTUAL_ENV}/bin/activate /home/mycroft/core/.venv/bin/activate

ENTRYPOINT ["sleep", "infinity"]
