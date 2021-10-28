ARG TAG=dev
FROM smartgic/mycroft-base:${TAG}

LABEL vendor=Smartgic.io \
      io.smartgic.maintainer="Gaëtan Trellu <gaetan.trellu@smartgic.io>" \
      io.smartgic.image-name="mycroft-enclosure" \
      io.smartgic.is-beta="no" \
      io.smartgic.is-production="no" \
      io.smartgic.version="${TAG}" \
      io.smartgic.release-date="2021-10-28"

WORKDIR /home/mycroft/core

USER mycroft

ENTRYPOINT ["python", "-m", "mycroft.client.enclosure"]
