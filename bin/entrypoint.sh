#!/usr/bin/env bash

test -z "$DEBUG" || set -x
set -ue

touch /etc/secrets.env

# If /data/secrets/secrets.yaml exists, then run summon and generate /etc/secrets.
if test -f /data/secrets/secrets.yaml; then
  /usr/local/bin/summon -p summon-aws-secrets -f /data/secrets/secrets.yaml \
    --ignore-all cat "@SUMMONENVFILE" > /etc/secrets.env
fi

# Run confd to generate configurations.
/usr/local/bin/godotenv -f /etc/secrets.env \
  /usr/local/bin/confd -confdir /etc/confd -onetime -backend=env

nginx -g "daemon off;"
