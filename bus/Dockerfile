ARG TAG=dev
FROM smartgic/mycroft-base:${TAG}

LABEL vendor=Smartgic.io \
      io.smartgic.maintainer="Gaëtan Trellu <gaetan.trellu@smartgic.io>" \
      io.smartgic.image-name="mycroft-bus" \
      io.smartgic.is-beta="no" \
      io.smartgic.is-production="no" \
      io.smartgic.version="${TAG}" \
      io.smartgic.release-date="2021-08-15"

WORKDIR /home/mycroft/core

USER mycroft

EXPOSE 8181

ENTRYPOINT ["python", "-m", "mycroft.messagebus.service"]
