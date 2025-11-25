const mongoose = require("mongoose");

const logSchema = new mongoose.Schema({
    deviceId: String,
    data: Object,
    timestamp: Number
});

module.exports = mongoose.model("Log", logSchema);
