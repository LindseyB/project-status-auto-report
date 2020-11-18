# Container image that runs your code
FROM alpine:3.10

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories && \
  apk add --no-cache \
  git \
  hub \
  bash \
  ruby

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
COPY generate-report.rb /
RUN chmod +x generate-report.rb

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
