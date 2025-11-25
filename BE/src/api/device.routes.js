const express = require("express");
const router = express.Router();
const deviceController = require("../controllers/deviceController");

router.post("/:id/command", deviceController.sendCommand);
router.get("/:id/state", deviceController.getDeviceState);

module.exports = router;
