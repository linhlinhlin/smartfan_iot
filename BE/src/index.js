require("dotenv").config();
const express = require("express");
const http = require("http");
const socketIo = require("socket.io");
const connectDB = require("./config/db");
const mqttSubscriber = require("./mqtt/subscriber");
const cors = require("cors");
const Device = require("./models/Device");
const timerService = require("./services/timerService");
const { sendCommand } = require("./mqtt/publisher");

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
    cors: {
        origin: "*", // Allow all origins for dev (Flutter app)
        methods: ["GET", "POST"]
    }
});

// Export io instance for use in controllers
module.exports = { io };

app.use(cors());
app.use(express.json());

/**
 * Restore active timers from database after server restart
 * Requirements: 5.1, 5.2, 5.3
 * 
 * Queries DB for devices with timerExpiresAt > now,
 * calculates remaining time, and restores setTimeout for each.
 */
async function restoreActiveTimers() {
    try {
        console.log("[TimerRestore] Starting timer restoration...");
        
        // Query DB for devices with active timers (timerExpiresAt > now)
        // Requirements: 5.1
        const activeDevices = await Device.find({
            'state.reported.timerExpiresAt': { $gt: new Date() }
        });

        if (activeDevices.length === 0) {
            console.log("[TimerRestore] No active timers found to restore");
            return;
        }

        console.log(`[TimerRestore] Found ${activeDevices.length} device(s) with active timers`);

        let restoredCount = 0;
        let expiredCount = 0;

        for (const device of activeDevices) {
            const deviceId = device.deviceId;
            const expiresAt = device.state.reported.timerExpiresAt;
            const remainingMs = expiresAt.getTime() - Date.now();

            // Requirements: 5.2 - Restore setTimeout with remaining duration
            if (remainingMs > 0) {
                const restored = timerService.restoreTimer(deviceId, expiresAt, async () => {
                    // Callback: Turn off fan when timer expires
                    console.log(`[TimerRestore] Restored timer expired for device ${deviceId}, turning off fan`);
                    
                    // Send POWER OFF command via MQTT
                    sendCommand(deviceId, 'POWER', 0);
                    
                    // Clear timer and update power state in DB
                    await Device.findOneAndUpdate(
                        { deviceId: deviceId },
                        { 
                            $set: { 
                                'state.reported.timerExpiresAt': null,
                                'state.reported.isOn': false
                            } 
                        }
                    );
                    
                    // Emit update to all connected clients
                    io.to(`device_${deviceId}`).emit('device_update', { 
                        timerExpiresAt: null,
                        isOn: false 
                    });
                });

                if (restored) {
                    const remainingMinutes = Math.ceil(remainingMs / 60000);
                    // Requirements: 5.3 - Log restoration action
                    console.log(`[TimerRestore] ✓ Restored timer for device: ${deviceId}, remaining: ${remainingMinutes} min, expires: ${expiresAt.toISOString()}`);
                    restoredCount++;
                }
            } else {
                // Timer already expired during server downtime - clean up
                console.log(`[TimerRestore] Timer already expired for device: ${deviceId}, cleaning up...`);
                
                // Clear expired timer from DB
                await Device.findOneAndUpdate(
                    { deviceId: deviceId },
                    { 
                        $set: { 
                            'state.reported.timerExpiresAt': null
                        } 
                    }
                );
                expiredCount++;
            }
        }

        console.log(`[TimerRestore] Restoration complete: ${restoredCount} restored, ${expiredCount} expired/cleaned`);
    } catch (error) {
        console.error("[TimerRestore] Error restoring timers:", error);
    }
}

// Database Connection
connectDB().then(() => {
    // Requirements: 5.1 - Call restoreActiveTimers after DB connection
    restoreActiveTimers();
});

// MQTT Subscriber (Pass io instance)
mqttSubscriber(io);

// Socket.IO Connection Handler
io.on("connection", (socket) => {
    console.log("New client connected:", socket.id);

    // Join room based on deviceId
    socket.on("join_device", (deviceId) => {
        socket.join(`device_${deviceId}`);
        console.log(`Client ${socket.id} joined room device_${deviceId}`);
    });

    socket.on("disconnect", () => {
        console.log("Client disconnected:", socket.id);
    });
});

// Routes
const deviceRoutes = require("./api/device.routes");
app.use("/api/devices", deviceRoutes);

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => console.log(`Server running on port ${PORT}`));