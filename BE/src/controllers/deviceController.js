const Device = require("../models/Device");
const { sendCommand } = require("../mqtt/publisher");

exports.sendCommand = async (req, res) => {
    try {
        const { id } = req.params;
        const { command, value } = req.body;

        // 1. Update Desired State in DB
        const updateField = {};
        if (command === 'POWER') updateField['state.desired.isOn'] = value == 1;
        if (command === 'MODE') updateField['state.desired.speed'] = parseInt(value);
        if (command === 'ROTATION') updateField['state.desired.isRotating'] = value == 1;
        if (command === 'AUTO') updateField['state.desired.isAuto'] = value == 1;

        // 1. Update Desired State in DB (Non-blocking)
        Device.findOneAndUpdate(
            { deviceId: id },
            { $set: updateField },
            { upsert: true }
        ).catch(err => console.error("DB Update Error:", err));

        // 2. Publish to MQTT
        sendCommand(id, command, value);

        res.json({ success: true, message: "Command sent" });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server Error" });
    }
};

exports.getDeviceState = async (req, res) => {
    try {
        const device = await Device.findOne({ deviceId: req.params.id });
        if (!device) return res.status(404).json({ message: "Device not found" });
        res.json(device.state.reported);
    } catch (error) {
        res.status(500).json({ message: "Server Error" });
    }
};
