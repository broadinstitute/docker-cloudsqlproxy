ARG DOCKER_TAG=1.33.6

FROM gcr.io/cloudsql-docker/gce-proxy:${DOCKER_TAG}

COPY entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh", "$@"]

