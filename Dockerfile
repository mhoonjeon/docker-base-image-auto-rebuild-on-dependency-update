FROM docker:stable

RUN apk add --update --no-cache curl jq

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
