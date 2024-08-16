# speedtest_docker

run it with docker compose:
  speedtest:
    image: speedtest:latest
    restart: unless-stopped
    container_name: speedtest
    environment:
      MQTT_USERNAME: "speedtest"
      MQTT_SERVER: "192.168.1.1"
      MQTT_PASSWORD: 'password'
      MQTT_TOPIC: "speedtest"
