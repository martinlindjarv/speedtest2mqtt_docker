FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq \
        mosquitto-clients \
        tini \
    && curl -fsSL \
        https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh \
        | bash \
    && apt-get install -y --no-install-recommends \
        speedtest \
    && rm -rf /var/lib/apt/lists/* \
    && useradd \
        --system \
        --no-create-home \
        --shell /usr/sbin/nologin \
        speedtest-runner

COPY --chown=speedtest-runner:speedtest-runner \
    speedtest_run.sh \
    run_loop.sh \
    /opt/

RUN chmod 0555 \
        /opt/speedtest_run.sh \
        /opt/run_loop.sh \
    && speedtest --version

USER speedtest-runner

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/opt/run_loop.sh"]
