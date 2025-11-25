require("dotenv").config();
const express = require("express");
const http = require("http");
const socketIo = require("socket.io");
const connectDB = require("./config/db");
const mqttSubscriber = require("./mqtt/subscriber");
const cors = require("cors");

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
    cors: {
        origin: "*", // Allow all origins for dev (Flutter app)
        methods: ["GET", "POST"]
    }
});

app.use(cors());
app.use(express.json());

// Database Connection
connectDB();

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