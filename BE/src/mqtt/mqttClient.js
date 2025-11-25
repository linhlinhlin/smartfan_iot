const mqtt = require("mqtt");

// Use MQTT_BROKER_URL from .env, or fallback to public broker
const brokerUrl = process.env.MQTT_BROKER_URL || "mqtt://broker.hivemq.com";

const client = mqtt.connect(brokerUrl, {
    username: process.env.MQTT_USERNAME,
    password: process.env.MQTT_PASSWORD
});

client.on("connect", () => {
    console.log(`MQTT connected to ${brokerUrl}`);
});

client.on("error", (err) => {
    console.log("MQTT error:", err);
});

module.exports = client;
