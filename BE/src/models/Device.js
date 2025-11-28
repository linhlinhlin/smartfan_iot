const mongoose = require("mongoose");

const deviceSchema = new mongoose.Schema({
    deviceId: { type: String, required: true, unique: true },
    info: {
        name: String,
        firmwareVersion: String
    },
    state: {
        reported: {
            isOn: Boolean,
            speed: Number,
            isRotating: Boolean,
            isAuto: Boolean,
            temperature: Number,
            humidity: Number,
            timerExpiresAt: Date,
            lastUpdatedAt: Date
        },
        desired: {
            isOn: Boolean,
            speed: Number,
            isRotating: Boolean,
            isAuto: Boolean,
            timerExpiresAt: Date
        }
    },
    lastSeen: Date
}, { timestamps: true });

module.exports = mongoose.model("Device", deviceSchema);
