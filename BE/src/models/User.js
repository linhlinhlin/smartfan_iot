const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
    email: String,
    password: String,
    devices: [String]   // danh sách deviceId
});

module.exports = mongoose.model("User", userSchema);