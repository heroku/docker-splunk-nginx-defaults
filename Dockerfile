FROM ubuntu:18.04 AS base-build
WORKDIR /root

RUN apt-get update -qq \
    && apt-get install -y curl

RUN curl -sSL https://github.com/cyberark/summon/releases/download/v0.6.8/summon.deb \
        -o /tmp/summon.deb \
      && dpkg -i /tmp/summon.deb \
      && apt-get install -f

# Install summon-aws-secrets
# https://github.com/cyberark/summon-aws-secrets
RUN curl -sSL https://github.com/cyberark/summon-aws-secrets/releases/download/v0.2.0/summon-aws-secrets-linux-amd64.tar.gz \
        -o /tmp/summon-aws-secrets.tar.gz \
      && mkdir -p /usr/local/lib/summon \
      && tar -C /usr/local/lib/summon -xvzf /tmp/summon-aws-secrets.tar.gz

RUN curl -sSL https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 \
        -o /usr/local/bin/confd \
    && chmod 755 /usr/local/bin/confd

FROM golang:1.10 AS go-build

ENV GOPATH /root/go
ENV GOBIN  /root/go/bin

RUN go get -v github.com/joho/godotenv/cmd/godotenv

FROM nginx

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && apt-get autoremove -y \
    && apt-get clean all \
    && apt-get purge -y \
    && rm -rf /var/lib/apt/lists/*

COPY --from=base-build /usr/local/bin/summon /usr/local/bin/
COPY --from=base-build /usr/local/lib/summon /usr/local/lib/summon
COPY --from=base-build /usr/local/bin/confd  /usr/local/bin/
COPY --from=go-build   /root/go/bin/godotenv /usr/local/bin/

# install confd files
COPY confd /etc/confd/
COPY bin/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN mkdir -p /data/www/

EXPOSE 80
STOPSIGNAL SIGTERM
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
