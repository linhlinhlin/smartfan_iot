const client = require("./mqttClient");

const sendCommand = (deviceId, command, value) => {
    const topic = `devices/${deviceId}/command`;
    const payload = JSON.stringify({
        command: command,
        value: value,
        ts: Date.now()
    });

    client.publish(topic, payload, { qos: 1 }, (err) => {
        if (err) {
            console.error(`Failed to publish to ${topic}:`, err);
        } else {
            console.log(`Published to ${topic}:`, payload);
        }
    });
};

module.exports = { sendCommand };
