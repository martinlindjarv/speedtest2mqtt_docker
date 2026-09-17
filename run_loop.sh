#!/bin/sh

set -eu

INITIAL_DELAY_SECONDS="${INITIAL_DELAY_SECONDS:-120}"
INTERVAL_SECONDS="${INTERVAL_SECONDS:-3600}"

validate_integer()
{
    name="$1"
    value="$2"

    case "$value" in
        ''|*[!0-9]*)
            echo "$name must be a non-negative integer" >&2
            exit 1
            ;;
    esac
}

validate_integer "INITIAL_DELAY_SECONDS" "$INITIAL_DELAY_SECONDS"
validate_integer "INTERVAL_SECONDS" "$INTERVAL_SECONDS"

if [ "$INTERVAL_SECONDS" -eq 0 ]; then
    echo "INTERVAL_SECONDS must be greater than zero" >&2
    exit 1
fi

echo "Speedtest MQTT service started"
echo "Initial delay: ${INITIAL_DELAY_SECONDS} seconds"
echo "Test interval: ${INTERVAL_SECONDS} seconds"

sleep "$INITIAL_DELAY_SECONDS"

while true; do
    if ! /opt/speedtest_run.sh; then
        echo "Speedtest or MQTT publishing failed" >&2
    fi

    sleep "$INTERVAL_SECONDS"
done
