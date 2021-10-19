ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache jq openssh-client zip

# Hass.io CLI
ARG BUILD_ARCH
ARG CLI_VERSION
RUN apk add --no-cache curl \
    && curl -Lso /usr/bin/hassio https://github.com/home-assistant/hassio-cli/releases/download/1.2.1/hassio_${BUILD_ARCH} \
    && chmod a+x /usr/bin/hassio

# Copy data
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]

# Build arugments
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="Respaldo Remoto" \
    io.hass.description="Crea un respaldo (aka snapshot) de manera automatica del HA y lo envia a un servidor remoto utilizando `SCP`. Inspirado en el script original de `Nicolai Bjerre Pedersen <mr.bjerre@gmail.com>`." \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Omar Orozco <oorozcoo@gmail.com>" \
    org.label-schema.description="Crea un respaldo de manera automatica del HA y lo envia a un servidor remoto utilizando `SCP`." \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name="Respaldo Remoto" \
    org.label-schema.schema-version="0.1-Alpha" \
    org.label-schema.usage="https://github.com/overkill32/hassio-remote-backup/tree/master/README.md" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://github.com/oorozcoo/hassio_addons/remote-backup/" \
    org.label-schema.vendor="Addons Omar Orozco"
