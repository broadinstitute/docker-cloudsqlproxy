ARG DOCKER_TAG=1.31.0

FROM gcr.io/cloudsql-docker/gce-proxy:${DOCKER_TAG}

COPY entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh", "$@"]

