#!/bin/sh

set -eu

: "${MQTT_SERVER:?MQTT_SERVER is required}"
: "${MQTT_TOPIC:?MQTT_TOPIC is required}"

MQTT_PORT="${MQTT_PORT:-1883}"
MQTT_USERNAME="${MQTT_USERNAME:-}"
MQTT_PASSWORD="${MQTT_PASSWORD:-}"

echo "Starting Ookla Speedtest..."

result=$(
    /usr/bin/speedtest \
        --accept-license \
        --accept-gdpr \
        --format=json
)

ping=$(
    printf '%s' "$result" |
        jq -er '.ping.latency'
)

jitter=$(
    printf '%s' "$result" |
        jq -er '.ping.jitter'
)

packet_loss=$(
    printf '%s' "$result" |
        jq -er '.packetLoss // 0'
)

# Ookla reports bandwidth in bytes per second.
# Convert bytes/s to megabits/s.
download=$(
    printf '%s' "$result" |
        jq -er '.download.bandwidth * 8 / 1000000'
)

upload=$(
    printf '%s' "$result" |
        jq -er '.upload.bandwidth * 8 / 1000000'
)

server=$(
    printf '%s' "$result" |
        jq -er '.server.name'
)

result_url=$(
    printf '%s' "$result" |
        jq -er '.result.url // empty'
)

publish()
{
    subtopic="$1"
    value="$2"

    set -- \
        --retain \
        --host "$MQTT_SERVER" \
        --port "$MQTT_PORT" \
        --topic "$MQTT_TOPIC/$subtopic" \
        --message "$value"

    if [ -n "$MQTT_USERNAME" ]; then
        set -- "$@" --username "$MQTT_USERNAME"
    fi

    if [ -n "$MQTT_PASSWORD" ]; then
        set -- "$@" --pw "$MQTT_PASSWORD"
    fi

    mosquitto_pub "$@"
}

publish "ping" "$ping"
publish "jitter" "$jitter"
publish "packet_loss" "$packet_loss"
publish "download" "$download"
publish "upload" "$upload"
publish "server" "$server"

if [ -n "$result_url" ]; then
    publish "result_url" "$result_url"
fi

# Publish the complete result as one retained JSON message too.
publish "json" "$result"

echo "Speedtest result published:"
echo "  Ping:        ${ping} ms"
echo "  Jitter:      ${jitter} ms"
echo "  Packet loss: ${packet_loss}%"
echo "  Download:    ${download} Mbps"
echo "  Upload:      ${upload} Mbps"
echo "  Server:      ${server}"
