ARG DOCKER_TAG=1.16

FROM gcr.io/cloudsql-docker/gce-proxy:${DOCKER_TAG} as distro


# Final Stage
FROM debian:buster-slim

COPY --from=distro /cloud_sql_proxy /cloud_sql_proxy

COPY entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh", "$@"]

