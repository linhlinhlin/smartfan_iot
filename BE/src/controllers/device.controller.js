const publish = require("../mqtt/publisher");
const Device = require("../models/Device");

exports.sendCommand = async (req, res) => {
    const { deviceId } = req.params;
    const { type, value } = req.body;

    publish(deviceId, { type, value });

    res.json({ ok: true, msg: "Command sent" });
};
