Kế hoạch của bạn về cơ bản là logic và khả thi cho một tính năng MVP (Minimum Viable Product). Tuy nhiên, có một số lỗ hổng kỹ thuật và trải nghiệm người dùng (UX) cần được tinh chỉnh để hệ thống chạy mượt mà và đồng bộ hơn giữa Server và App.

Dưới đây là nhận xét chi tiết và các đề xuất cải tiến:

1. Vấn đề cốt lõi cần xem xét (Critical Issues)
A. Cách lưu trữ và đồng bộ thời gian (Quan trọng nhất)

Hiện tại: Bạn định lưu remaining minutes hoặc duration.

Vấn đề: Thời gian trôi đi từng giây. Nếu Backend chỉ lưu "60 phút", thì 10 phút sau, Frontend làm sao biết còn "50 phút" để hiển thị? Frontend sẽ phải hỏi Backend liên tục hoặc tự đếm (gây lệch nếu App bị tắt rồi mở lại).

Giải pháp: Backend nên tính toán và lưu expiresAt (Thời điểm kết thúc - Timestamp) thay vì độ dài thời gian.

Ví dụ: Set timer 60 phút vào lúc 10:00. Backend lưu expiresAt = 11:00.

Backend gửi expiresAt về Frontend.

Frontend tự lấy Current Time so sánh với expiresAt để hiển thị countdown realtime mà không cần gọi API liên tục.

B. Xung đột trạng thái (State Conflict)

Kịch bản: Người dùng hẹn giờ 8 tiếng. Sau 1 tiếng, người dùng tự tắt quạt (Manual OFF). Sau đó bật lại quạt.

Vấn đề: Timer cũ (còn 7 tiếng) có nên tiếp tục chạy không? Thông thường, nếu quạt bị tắt (Power OFF), hẹn giờ (Sleep Timer) nên bị hủy tự động.

Giải pháp: Trong deviceController.js, khi nhận lệnh POWER OFF hoặc POWER ON, cần kiểm tra và hủy timer đang chạy của thiết bị đó.

C. Persistence (Lưu trữ)

Bạn chọn In-memory (biến mất khi restart server). Điều này chấp nhận được cho MVP. Tuy nhiên, nếu server restart, người dùng sẽ không biết là hẹn giờ đã bị mất -> Quạt chạy mãi không tắt -> Tốn điện.

Gợi ý: Nếu có thể, hãy lưu expiresAt vào Database. Khi server khởi động lại, nó sẽ query DB xem có timer nào expiresAt > now thì setTimeout lại phần dư, hoặc nếu expiresAt < now (đã quá hạn trong lúc server chết) thì gửi lệnh tắt ngay lập tức.

2. Implementation Plan Đã Tinh Chỉnh

Dưới đây là phiên bản cập nhật cho kế hoạch của bạn để xử lý các vấn đề trên:

Backend (Node.js)

1. timerService.js

Sử dụng một Map<deviceId, { timeoutId, expiresAt }> để quản lý.

setTimer(deviceId, durationInMinutes, callback):

Calculate expiresAt = Date.now() + durationInMinutes * 60000.

Clear timer cũ nếu tồn tại.

Set setTimeout.

Lưu vào Map.

Return expiresAt.

cancelTimer(deviceId): Clear timeout, xóa khỏi Map, return success.

getTimerInfo(deviceId): Return { expiresAt } hoặc null.

2. deviceController.js

Handle TIMER command:

Gọi timerService.setTimer.

Cập nhật DB: Device.state.timerExpiresAt = expiresAt.

Emit Socket: { type: 'TIMER_UPDATE', deviceId, expiresAt }.

Handle POWER command:

Nếu lệnh là OFF: Gọi timerService.cancelTimer(deviceId).

Cập nhật DB: Xóa timerExpiresAt (set null).

Emit Socket: Cập nhật trạng thái quạt và timer (null).

3. Device.js (Model)

Thay vì timer (int), hãy thêm field: timerExpiresAt (Date/Timestamp).

Frontend (Flutter)

1. Data Models (fan_model.dart / fan_entity.dart)

Đổi int timer thành DateTime? timerExpiresAt.

Khi parse JSON: timerExpiresAt = json['timerExpiresAt'] != null ? DateTime.parse(json['timerExpiresAt']) : null;

2. UI Logic (smart_fan_screen.dart & fan_provider.dart)

Hiển thị:

Sử dụng một Timer.periodic cục bộ trong Widget (mỗi giây chạy 1 lần) để tính: remaining = timerExpiresAt - DateTime.now().

Format remaining thành HH:mm:ss để hiển thị lên UI.

Nếu remaining <= 0, ẩn UI timer.

Action:

Gửi lệnh lên server: Vẫn gửi số phút (ví dụ: 60). Server sẽ lo phần tính toán timestamp.

3. Verification Plan (Bổ sung)

Thêm các case test quan trọng sau vào Manual Verification:

Test Sync:

Set timer 60 phút trên điện thoại A.

Mở điện thoại B (cùng account).

Điện thoại B phải hiển thị đúng thời gian còn lại (ví dụ 59:30) ngay lập tức.

Test Manual Override:

Set timer 10 phút.

Bấm nút Tắt quạt trên App.

Bật lại quạt.

Kiểm tra xem Timer có bị hủy không (Nên bị hủy).

Test App Restart:

Set timer 30 phút.

Kill App Flutter (tắt hẳn).

Chờ 5 phút.

Mở lại App.

Thời gian còn lại phải là ~25 phút (Không phải reset về 30, cũng không phải mất timer).

Kết luận

Kế hoạch gốc của bạn ở mức 6/10 (chạy được nhưng UX kém và dễ lỗi logic).
Nếu áp dụng việc sử dụng expiresAt (Timestamp) và logic hủy timer khi tắt quạt, kế hoạch sẽ đạt 9/10 cho một tính năng ổn định.
