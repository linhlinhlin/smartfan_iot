const mqtt = require("mqtt");

// Cấu hình giống trong .env của Backend
const BROKER_URL = "mqtt://broker.hivemq.com";
const DEVICE_ID = "quat_thong_minh_2";

const client = mqtt.connect(BROKER_URL);

// Trạng thái giả lập của quạt
let state = {
    isOn: false,
    speed: 1,
    isRotating: false,
    isAuto: false,
    temperature: 28.5,
    humidity: 60
};

client.on("connect", () => {
    console.log(`✅ Device ${DEVICE_ID} connected to MQTT Broker`);

    // Lắng nghe lệnh từ Backend
    client.subscribe(`devices/${DEVICE_ID}/command`);

    // Gửi trạng thái định kỳ (giả lập cảm biến)
    setInterval(() => {
        // Tự động thay đổi nhiệt độ chút xíu cho sinh động
        state.temperature += (Math.random() - 0.5) * 0.2;
        publishState();
    }, 5000); // 5 giây gửi 1 lần
});

client.on("message", (topic, message) => {
    const payload = JSON.parse(message.toString());
    console.log(`📩 Received Command:`, payload);

    // Xử lý lệnh
    if (payload.command === 'POWER') {
        state.isOn = payload.value == 1;
    } else if (payload.command === 'MODE') {
        state.speed = parseInt(payload.value);
    } else if (payload.command === 'ROTATION') {
        state.isRotating = payload.value == 1;
    } else if (payload.command === 'AUTO') {
        state.isAuto = payload.value == 1;
    }

    // Gửi lại trạng thái mới ngay lập tức để App cập nhật
    publishState();
});

function publishState() {
    const topic = `devices/${DEVICE_ID}/status`;
    const payload = JSON.stringify(state);
    client.publish(topic, payload);
    console.log(`📤 Published State: Temp=${state.temperature.toFixed(1)}°C, On=${state.isOn}, Speed=${state.speed}`);
}
