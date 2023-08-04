FROM gcr.io/cloudsql-docker/gce-proxy:1.33.6-alpine

RUN apk update && apk upgrade --no-cache

COPY entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh", "$@"]

