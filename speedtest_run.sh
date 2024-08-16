#!/bin/sh

# Do not run exactly at 0 minute - it will not work!

speedtest_result=$(/usr/bin/speedtest-cli --simple --secure)

ping=$(echo "$speedtest_result" | grep "Ping" |awk '{print $2}')
download=$(echo "$speedtest_result" | grep "Download" |awk '{print $2}')
upload=$(echo "$speedtest_result" | grep "Upload" |awk '{print $2}')

mosquitto_pub --retain --topic $MQTT_TOPIC/ping -u $MQTT_USERNAME -P $MQTT_PASSWORD -h $MQTT_SERVER -p 1883 -m "$ping"
mosquitto_pub --retain --topic $MQTT_TOPIC/download -u $MQTT_USERNAME -P $MQTT_PASSWORD -h $MQTT_SERVER -p 1883 -m "$download"
mosquitto_pub --retain --topic $MQTT_TOPIC/upload -u $MQTT_USERNAME -P $MQTT_PASSWORD -h $MQTT_SERVER -p 1883 -m "$upload"
