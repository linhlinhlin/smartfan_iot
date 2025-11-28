const Device = require("../models/Device");
const { sendCommand } = require("../mqtt/publisher");
const timerService = require("../services/timerService");

// Get io instance (lazy load to avoid circular dependency)
const getIO = () => require("../index").io;

exports.sendCommand = async (req, res) => {
    try {
        const { id } = req.params;
        const { command, value } = req.body;
        
        console.log(`[DeviceController] Received command: ${command}, value: ${value}, deviceId: ${id}`);

        // 1. Update Desired State in DB
        const updateField = {};
        if (command === 'POWER') updateField['state.desired.isOn'] = value == 1;
        if (command === 'MODE') updateField['state.desired.speed'] = parseInt(value);
        if (command === 'ROTATION') updateField['state.desired.isRotating'] = value == 1;
        if (command === 'AUTO') updateField['state.desired.isAuto'] = value == 1;

        // Handle TIMER command
        // Requirements: 1.1, 1.3, 2.1, 2.2
        if (command === 'TIMER') {
            const io = getIO();
            const minutes = parseInt(value);

            if (minutes > 0) {
                // Set timer: calculate expiresAt, store in DB, emit socket event
                try {
                    const expiresAt = timerService.setTimer(id, minutes, async () => {
                        // Callback: Turn off fan when timer expires
                        console.log(`[Timer] Timer expired for device ${id}, turning off fan`);
                        
                        // Send POWER OFF command via MQTT
                        sendCommand(id, 'POWER', 0);
                        
                        // Clear timer and update power state in DB
                        await Device.findOneAndUpdate(
                            { deviceId: id },
                            { 
                                $set: { 
                                    'state.reported.timerExpiresAt': null,
                                    'state.reported.isOn': false
                                } 
                            }
                        );
                        
                        // Emit update to all connected clients
                        if (io) {
                            io.to(`device_${id}`).emit('device_update', { 
                                timerExpiresAt: null,
                                isOn: false 
                            });
                        }
                    });

                    // Save expiresAt to DB
                    await Device.findOneAndUpdate(
                        { deviceId: id },
                        { 
                            $set: { 
                                'state.reported.timerExpiresAt': expiresAt,
                                'state.desired.timerExpiresAt': expiresAt
                            } 
                        },
                        { upsert: true }
                    );

                    // Emit timer set event to all connected clients
                    if (io) {
                        io.to(`device_${id}`).emit('device_update', { 
                            timerExpiresAt: expiresAt.toISOString() 
                        });
                    }

                    return res.json({ 
                        success: true, 
                        message: "Timer set", 
                        timerExpiresAt: expiresAt.toISOString() 
                    });
                } catch (timerError) {
                    console.error("[Timer] Error setting timer:", timerError.message);
                    return res.status(400).json({ 
                        success: false, 
                        message: timerError.message 
                    });
                }
            } else {
                // Cancel timer: clear expiresAt, emit socket event
                timerService.cancelTimer(id);

                // Clear timer in DB
                await Device.findOneAndUpdate(
                    { deviceId: id },
                    { 
                        $set: { 
                            'state.reported.timerExpiresAt': null,
                            'state.desired.timerExpiresAt': null
                        } 
                    }
                );

                // Emit timer cancelled event to all connected clients
                if (io) {
                    io.to(`device_${id}`).emit('device_update', { 
                        timerExpiresAt: null 
                    });
                }

                return res.json({ 
                    success: true, 
                    message: "Timer cancelled" 
                });
            }
        }

        // Handle POWER command - cancel timer when turning off
        // Requirements: 3.1, 3.2
        if (command === 'POWER' && value == 0) {
            const io = getIO();
            
            // Cancel any active timer when manually turning off
            const hadTimer = timerService.cancelTimer(id);
            
            if (hadTimer) {
                console.log(`[Timer] Timer cancelled due to manual power off for device ${id}`);
                
                // Clear timer in DB
                updateField['state.reported.timerExpiresAt'] = null;
                updateField['state.desired.timerExpiresAt'] = null;
                
                // Emit timer cancelled event
                if (io) {
                    io.to(`device_${id}`).emit('device_update', { 
                        timerExpiresAt: null 
                    });
                }
            }
        }

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
