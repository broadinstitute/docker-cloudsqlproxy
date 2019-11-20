ARG DOCKER_TAG=1.16

FROM gcr.io/cloudsql-docker/gce-proxy:${DOCKER_TAG}

COPY entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh", "$@"]

