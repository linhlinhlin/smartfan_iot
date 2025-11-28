const client = require("./mqttClient");
const Device = require("../models/Device");
const Log = require("../models/Log");

// We need to inject IO instance or use a singleton. 
// For simplicity, we'll export a function that takes io.
module.exports = (io) => {
    client.on("connect", () => {
        console.log("MQTT Connected");
        client.subscribe("fan/+/data");
        client.subscribe("devices/+/status");
    });

    client.on("message", async (topic, message) => {
        try {
            let deviceId;
            if (topic.startsWith("fan/")) {
                deviceId = topic.split("/")[1];
            } else if (topic.startsWith("devices/")) {
                deviceId = topic.split("/")[1];
            }

            const messageStr = message.toString();
            let rawData;

            try {
                rawData = JSON.parse(messageStr);
            } catch (e) {
                console.log(`Received non-JSON message from ${deviceId}: ${messageStr}`);
                return; // Skip processing if not JSON
            }

            console.log(`Received from ${deviceId}:`, rawData);

            // Map data to standard schema
            const cleanData = {
                isOn: rawData.isOn ?? (rawData.dang_bat === true || rawData.dang_bat === 1 || rawData.trang_thai === 'BAT'),
                speed: rawData.speed ?? rawData.power ?? rawData.toc_do,
                isRotating: rawData.isRotating ?? (rawData.dang_xoay === true || rawData.dang_xoay === 1),
                isAuto: rawData.isAuto ?? (rawData.che_do === 'tu_dong' || rawData.auto === 1),
                temperature: rawData.temperature ?? rawData.nhiet_do,
                humidity: rawData.humidity ?? rawData.do_am,
                lastUpdatedAt: new Date()
            };

            // Update Device Shadow (Reported State) and get updated document
            const updatedDevice = await Device.findOneAndUpdate(
                { deviceId },
                {
                    $set: {
                        "state.reported.isOn": cleanData.isOn,
                        "state.reported.speed": cleanData.speed,
                        "state.reported.isRotating": cleanData.isRotating,
                        "state.reported.isAuto": cleanData.isAuto,
                        "state.reported.temperature": cleanData.temperature,
                        "state.reported.humidity": cleanData.humidity,
                        "state.reported.lastUpdatedAt": cleanData.lastUpdatedAt,
                        lastSeen: new Date()
                    }
                },
                { upsert: true, new: true }
            );

            // Log history
            await Log.create({
                deviceId,
                data: cleanData,
                timestamp: Date.now()
            });

            // Include timerExpiresAt from DB in socket emission for multi-device sync
            const socketData = {
                ...cleanData,
                timerExpiresAt: updatedDevice?.state?.reported?.timerExpiresAt || null
            };

            // Emit to Socket.IO (Realtime to App)
            io.to(`device_${deviceId}`).emit("device_update", socketData);

        } catch (error) {
            console.error("MQTT Message Error:", error);
        }
    });
};
