FROM alpine:latest

RUN apk add speedtest-cli mosquitto-clients

COPY speedtest_run.sh /opt/speedtest_run.sh

RUN chmod 755 /opt/speedtest_run.sh

# run only specific script ie. remove other crons
RUN echo '2  *  *  *  *    /opt/speedtest_run.sh' > /etc/crontabs/root

CMD crond -l 2 -f
