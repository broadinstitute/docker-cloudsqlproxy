FROM gcr.io/cloudsql-docker/gce-proxy:1.33.13-alpine

USER root
RUN apk update && apk upgrade --no-cache
USER nonroot

COPY entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh", "$@"]

