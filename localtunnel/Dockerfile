ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache git nodejs npm jq curl

#Install localtunnel
RUN git clone https://github.com/localtunnel/localtunnel.git
RUN cd localtunnel
RUN npm install -g localtunnel

# Copy data
COPY run.sh /
RUN chmod a+x /run.sh

#Ejecute localtunnel
CMD [ "/run.sh" ]
