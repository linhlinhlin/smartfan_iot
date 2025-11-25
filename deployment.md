# Hướng dẫn Deploy Cloud & Build App

Tài liệu này hướng dẫn bạn đưa Backend lên Cloud (Render.com) và xuất file APK để cài vào điện thoại Android.

## Phần 1: Deploy Backend lên Render.com (Miễn phí)

Để App điều khiển được quạt từ bất cứ đâu (qua 4G/WiFi khác), Backend cần được đưa lên mạng internet.

### Bước 1: Đẩy code lên GitHub
Bạn cần có một tài khoản GitHub và tạo một repository mới.
1.  Mở terminal tại thư mục gốc dự án (`e:\vmu\IOT\smart_fan`).
2.  Chạy các lệnh sau:
    ```bash
    git add .
    git commit -m "Prepare for deployment"
    # Thay URL bên dưới bằng URL repo của bạn
    git remote add origin https://github.com/USERNAME/REPO_NAME.git 
    git branch -M main
    git push -u origin main
    ```

### Bước 2: Tạo Web Service trên Render
1.  Đăng ký/Đăng nhập tại [dashboard.render.com](https://dashboard.render.com/).
2.  Chọn **New +** -> **Web Service**.
3.  Chọn **Build and deploy from a Git repository**.
4.  Kết nối GitHub và chọn repo bạn vừa đẩy lên.
5.  Cấu hình:
    *   **Name**: `smart-fan-backend` (tùy chọn)
    *   **Region**: Singapore (cho nhanh)
    *   **Runtime**: Node
    *   **Build Command**: `cd BE && npm install`
    *   **Start Command**: `cd BE && npm start`
    *   **Instance Type**: Free
6.  **Environment Variables** (Quan trọng):
    Nhấn **Add Environment Variable** và thêm các biến từ file `BE/.env`:
    *   `MONGO_URI`: (Copy từ file .env)
    *   `MQTT_BROKER_URL`: `mqtt://broker.hivemq.com`
    *   `MQTT_USERNAME`: (Để trống hoặc copy nếu có)
    *   `MQTT_PASSWORD`: (Để trống hoặc copy nếu có)
    *   `JWT_SECRET`: (Tự đặt một chuỗi bí mật)
7.  Nhấn **Create Web Service**.

Chờ khoảng 2-3 phút. Khi thấy `Your service is live`, hãy copy đường dẫn URL (ví dụ: `https://smart-fan-backend.onrender.com`).

---

## Phần 2: Cập nhật App Flutter

Sau khi có URL của Backend trên Cloud, bạn cần cập nhật vào App.

1.  Mở file `FE/lib/main.dart`.
2.  Tìm đoạn `NodeJsFanRepositoryImpl`.
3.  Thay đổi `baseUrl` và `socketUrl`:
    ```dart
    repository: NodeJsFanRepositoryImpl(
      // Thay bằng URL bạn vừa copy từ Render (bỏ dấu / ở cuối nếu có)
      baseUrl: 'https://smart-fan-backend.onrender.com/api',
      socketUrl: 'https://smart-fan-backend.onrender.com',
    ),
    ```

---

## Phần 3: Xuất file APK (Build)

Để cài lên điện thoại Android:

1.  Mở terminal tại thư mục `FE`:
    ```bash
    cd FE
    flutter build apk --release
    ```
2.  Chờ quá trình build hoàn tất.
3.  File APK sẽ nằm tại:
    `FE/build/app/outputs/flutter-apk/app-release.apk`

4.  Copy file này vào điện thoại và cài đặt.

---

## Lưu ý quan trọng
*   **Thiết bị thật (ESP8266)**: Không cần nạp lại code. Nó kết nối tới MQTT Broker công cộng (`broker.hivemq.com`) nên Backend ở đâu (Local hay Cloud) cũng đều điều khiển được.
*   **Độ trễ**: Khi dùng Cloud, độ trễ có thể tăng nhẹ so với mạng LAN, nhưng nhờ cơ chế **Optimistic UI** chúng ta đã làm, cảm giác bấm nút vẫn sẽ tức thì.
