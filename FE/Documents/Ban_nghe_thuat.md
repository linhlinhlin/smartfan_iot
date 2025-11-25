Tuyệt vời. Dưới đây là **bản thiết kế nghệ thuật chi tiết** cho app “Điều khiển Quạt Thông minh – đơn thiết bị”, bám sát phong cách **Neo-futurism × Blockchain ẩn dụ × Vũ trụ trắng**. Mình mô tả **layout, bố cục, quy tắc UX/UI, trạng thái, chuyển động, microcopy** cho **từng phần** — đủ để bạn dựng trực tiếp (Flutter/Material 3) hoặc chuyển Figma.

---

# 0) Nguyên lý thẩm mỹ & triết lý UX

* **Neo-futurism**: bề mặt trắng tinh, lưới kỷ luật, viền mảnh, ánh xanh băng tinh tế (ice-blue).
* **Blockchain ẩn dụ**: thông tin như “khối dữ liệu” (card block), nhật ký “chuỗi block”, trường trạng thái có chữ ký (ts/by).
* **Tối giản đơn thiết bị**: **1 màn hình chính** (Dashboard), **2 màn phụ** (Login, Profile/Settings).
* **Tập trung “1–2 chạm”** cho Power/Mode/Rotate/Auto.
* **Tương phản & nhịp điệu**: chữ đen xám trên nền trắng, số liệu lớn – nhãn nhỏ, khoảng trắng rộng để “thở”.

---

# 1) Thiết lập hệ thống (Design System)

## 1.1 Lưới & khoảng cách

* **Grid 8pt**.
* **Padding màn hình**: 20–24px.
* **Khoảng cách dọc**: xs 8, sm 12, md 16, lg 24, xl 32.
* **Card radius**: 16px; **Chip radius**: 12px; **Segment radius**: 12px.
* **Viền mảnh**: 1px `rgba(0,0,0,0.06)` để “nổi khối”.

## 1.2 Màu & tokens

* **Base/Background**: `#FFFFFF`
* **Surface**: `#F4F6F8`
* **Text/Primary**: `#2A2F36` • **Text/Secondary**: `#5A6472`
* **Accent/Ice-Blue**: `#8AD5FF` (highlight, focus, ON glow)
* **Semantic**: Success `#21C274`, Warning `#FFB020`, Error `#F55555`
* **Elevations**: card 2 (bóng rất nhẹ).

## 1.3 Chữ & thang đo

* **Font**: Inter/SF Pro.
* **Display** 40–48 (số liệu lớn), **Title** 20–22, **Body** 14–16, **Caption** 12–13.
* **Weight**: 600 cho tiêu đề/giá trị chính; 400–500 cho mô tả.

## 1.4 Icon & chuyển động

* **Icon**: đường nét mảnh, outline.
* **Motion**: linear-ease 150–220ms; **Power ON** → glow nhẹ + fan glyph quay 6–12°.
* **Haptic**: nhẹ khi thao tác thành công; haptic cảnh báo khi rollback.

---

# 2) Kiến trúc màn hình & luồng

## 2.1 Sơ đồ IA

* **Login** → **Dashboard** (mặc định) → **Profile & Settings** (sheet hoặc route).
* FAB Micro từ Dashboard mở **Voice Assistant Sheet** (toàn chiều ngang).

## 2.2 Wireframe tổng quát (ASCII – điện thoại 390×844)

```
┌──────────────────────────────────────┐
│ AppBar: Quạt Phòng Khách   [● Online│
│        (Title semibold)      Chip ]  │
├──────────────────────────────────────┤
│ Card: Cảm biến (StatCard)            │
│  ┌───────────────┐  ┌──────────────┐ │
│  │🌡 26.3° C     │  │💧 55%        │ │
│  │caption: 10s ago│ │caption: ổn định│ │
│  └───────────────┘  └──────────────┘ │
├──────────────────────────────────────┤
│ Card: Điều khiển                     │
│  Power:  [  LARGE SWITCH   ]         │
│  Speed:  [ ① ][ ② ][ ③ ]            │
│  Toggles:[ ↻ Xoay ]   [ A Auto ]     │
├──────────────────────────────────────┤
│ Caption: Lần cập nhật: 10 giây trước│
├──────────────────────────────────────┤
│ FAB Micro  ◉                         │
└──────────────────────────────────────┘
(Voice Assistant mở dưới dạng bottom sheet phủ 70% chiều cao)
```

---

# 3) Màn hình chi tiết

## 3.1 Login (ẩn danh mặc định)

**Mục tiêu**: vào Dashboard nhanh nhất, vẫn hỗ trợ email/password.

* **Layout**

  * Logo/quạt glyph nhỏ (trung tâm, opacity 0.8).
  * Title: “Chào mừng”.
  * Nút **“Đăng nhập ẩn danh”** (Primary, full width).
  * Separator mảnh, chữ “hoặc”.
  * Form Email/Password (2 ô + nút “Đăng nhập”).
  * Footer: version nhỏ, link “Chính sách quyền riêng tư”.
* **UX**

  * Nếu ẩn danh thành công → chuyển ngay Dashboard.
  * Loading nút dạng progress inline.
  * Lỗi hiển thị ngắn gọn: “Email hoặc mật khẩu không đúng”.

**Kích thước gợi ý**

* Padding: 24; spacing giữa khối: 24–32.
* Nút lớn cao 52–56.

---

## 3.2 Dashboard (màn hình trung tâm)

### A) AppBar

* **Trái**: Tựa đề “Quạt Phòng Khách” (Title 20–22, w600).
* **Phải**: **StatusChip**

  * Online: nền `rgba(33,194,116,0.12)` + text xanh lá
  * Offline: nền xám nhạt + text xám
  * Nội dung: “● Hoạt động” / “○ Mất kết nối”

> Khi Offline, **vô hiệu hoá** FAB Micro & các control có tác dụng tức thời (giữ được điều khiển nhưng bật tooltip “Thiết bị offline”).

### B) Card Cảm biến (StatCard)

* **2 khối ngang**: Nhiệt độ & Độ ẩm.
* **Anatomy mỗi khối**:

  * Icon mảnh (24px) bên trái tiêu đề nhỏ (Caption “Nhiệt độ”).
  * **Giá trị lớn** (Display 40–44) + **đơn vị** (Title 18).
  * **Phụ đề** (Caption): “cập nhật 10s trước / ổn định / +0.2°” (tùy data).
* **Trạng thái**

  * Loading: skeleton 2 dòng + placeholder icon.
  * Error/No data: “Chưa có dữ liệu”, icon cloud-off, gợi ý “kiểm tra kết nối”.

### C) Card Điều khiển

1. **PowerSwitchLarge**

   * Dạng pill 64–72px chiều cao, chiếm trọn chiều ngang card.
   * **ON**: nền trắng, viền mảnh, **glow ice-blue** 1–2px bên trong. Icon fan nhẹ xoay (6–12°) khi bật.
   * **OFF**: nền `#F7F8FA`, chữ xám; hover/press tối hơn 4–6%.
   * Nhãn trái: “Nguồn”; nhãn phải: “Bật/Tắt” (thay đổi theo trạng thái).
2. **ModeSegmented (1–3)**

   * 3 segment ngang, width bằng nhau; selected có **inner-glow** ice-blue rất nhẹ; label là số **① ② ③** hoặc “1 2 3”.
   * Tapping đổi ngay (optimistic), 150–180ms animation.
3. **ToggleRow**

   * 2 switch: **↻ Xoay** và **A Auto**.
   * Khi bật: label đậm hơn 10–15%; switch màu accent mờ (không quá chói).

**Hành vi (logic UX)**

* Mọi thao tác **optimistic** → đổi trạng thái ngay; nếu không nhận “OK” từ log trong 3–5s → rollback + Toast lỗi “Không thực thi được lệnh. Thử lại.”
* Khi **Auto** bật, nếu **Mode** do người dùng đổi → hiển thị Banner mảnh “Auto đang bật, tốc độ có thể bị điều chỉnh tự động”.

### D) Nhãn thời gian

* Dưới cùng: “Lần cập nhật: 10 giây trước”.
* Khi >30s: chuyển “Thiết bị có thể đang ngoại tuyến”.

### E) FAB Micro

* Hình tròn 56px, icon mic; bóng nhẹ (elevation 3).
* Tooltip: “Nhấn để nói”.

---

## 3.3 Voice Assistant Sheet (70% chiều cao)

**Mục tiêu**: ghi âm – hiểu lệnh – phản hồi mạch lạc.

* **Header**: “Trợ lý quạt thông minh” + nút đóng (x).
* **Waveform Panel** (chiếm 40–50% chiều cao sheet)

  * Nền trắng, viền mảnh; waveform realtime.
  * Dòng status: “Đang nghe…” / “Đang hiểu lệnh…” / “Đang thực thi…”.
* **Transcript tạm**: body 16, màu textSecondary; xuất hiện ngay khi ASR cung cấp kết quả tạm.
* **Phản hồi**: thẻ nhỏ hiển thị kết quả (ví dụ: `POWER_ON`, `MODE_2`) trước khi TTS phát.
* **Action Row**:

  * Nút **Giữ-để-nói** (hold-to-speak) hoặc Toggle **Bấm-để-nói**.
  * Nút phụ “Huỷ”.
* **Trạng thái & lỗi**

  * Quyền mic bị từ chối → hiển thị card cảnh báo + nút “Mở cài đặt quyền”.
  * LLM lỗi → Toast “Tôi chưa hiểu. Bạn nói lại nhé.” + đề xuất lệnh mẫu (“Bật quạt”, “Tốc độ 2”, “Bật xoay”).
* **Âm thanh & haptic**

  * Beep nhẹ khi bắt đầu/ kết thúc ghi.
  * Haptic nhẹ khi thực thi lệnh xong.

---

## 3.4 Profile & Settings (sheet hoặc route)

* **Tài khoản**: Avatar chữ (A/Ẩ), “Anonymous” hoặc email, UID (copyable).
* **API Keys**

  * **Gemini API Key** (secure field, ẩn ký tự) + nút “Kiểm tra”.
  * **ElevenLabs API Key** + **Voice ID** + nút “Kiểm tra”.
  * Thông báo kết quả: chip success/error.
* **Tuỳ chọn**: Ngôn ngữ (vi/en), Đơn vị °C/°F.
* **Đăng xuất**: nút Text “Đăng xuất” (màu error ẩn dụ), xác nhận 1 bước.

**UX**

* Lưu tự động khi mất focus (debounce 500ms).
* Nếu key sai → thông báo rõ: “Key không hợp lệ hoặc hết hạn”.

---

# 4) Trạng thái, ràng buộc & vi mô (Micro-interactions)

## 4.1 Optimistic & Rollback

* Khi user đổi switch/segment → UI đổi ngay.
* Lắng `nhat_ky` hoặc result callback: nếu `ERR`/timeout → trả về trạng thái cũ + Toast đỏ.

## 4.2 Online/Offline

* **Online**: chip xanh lá; FAB Micro hoạt động.
* **Offline (>30s)**: chip xám; **disable** FAB & hiển thị banner mảnh “Thiết bị ngoại tuyến”.

## 4.3 Loading/Empty/Error

* **Loading**: skeleton cho StatCard; control hiển thị nhưng mờ (opacity 0.6).
* **Empty**: “Chưa có dữ liệu cảm biến”; gợi ý kiểm tra kết nối.
* **Error**: card lỗi (viền đỏ rất nhạt), icon warning + copy ngắn.

## 4.4 Phản hồi

* **Snack/Toast**:

  * Thành công: “Đã bật quạt”, “Đã chuyển tốc độ 2”.
  * Lỗi: “Không thực thi được lệnh. Thử lại.”
* **Haptic**: selection nhẹ (success), impact nhẹ (error).

## 4.5 Truy vết (blockchain ẩn dụ)

* Trang **Nhật ký** (nếu thêm sau): timeline dọc — mỗi mục là “khối”: `time • action • by(uid…) • result` + short id (6 ký tự từ pushId).

---

# 5) Quy tắc tương tác (Heuristics)

* **Tiên lượng ý định**:

  * Khả năng “Giữ-để-nói” và “Bấm-để-nói” (toggle mode) để phù hợp thói quen.
* **Giảm sai số**:

  * Trong Voice Sheet, gợi ý mẫu lệnh ngắn luôn hiển thị ở dưới.
* **Tối thiểu chữ**:

  * Label ngắn, icon rõ; số liệu lớn để mắt quét nhanh.
* **Khả năng tiếp cận**:

  * Target ≥ 44px, contrast ≥ 4.5:1, hỗ trợ screen reader (label icon: “Bật nguồn”, “Tốc độ 2”, “Bật xoay”).
* **Nhất quán ngôn ngữ**:

  * “Bật/Tắt”, “Tốc độ 1/2/3”, “Xoay”, “Tự động”.

---

# 6) Component anatomy (chi tiết dựng)

### 6.1 `StatusChip`

* **ON**: nền `rgba(33,194,116,0.12)`, dot xanh lá, text “Hoạt động”.
* **OFF**: nền `rgba(0,0,0,0.06)`, dot xám, text “Mất kết nối”.
* Padding ngang 10–12, cao 28–30.

### 6.2 `StatCard(title, value, unit, subtitle)`

* Card radius 16, viền mảnh, padding 16.
* Title (caption), Value (display), Unit (title), Subtitle (caption secondary).
* Responsive: nếu màn nhỏ, xếp dọc; lớn, xếp 2 cột.

### 6.3 `PowerSwitchLarge`

* Chiều cao 64–72, bo 32–36, icon fan trái, label phải.
* ON: inner-glow ice-blue (blur 8–12, opacity 0.2), icon rotate nhẹ khi thay đổi.
* OFF: nền surface nhạt.

### 6.4 `ModeSegmented`

* 3 segment equal; spacing 8; border pill.
* Selected: inner-glow nhẹ + text đậm.

### 6.5 `ToggleRow`

* Hai switch cách nhau 16–24, label bên trái, switch bên phải.

### 6.6 `VoiceFAB` & `VoiceSheet`

* FAB 56; sheet với waveform chiếm 40–50% chiều cao.
* Nút giữ-để-nói: vòng nhịp (pulse) khi đang ghi.

---

# 7) Layout đo lường (gợi ý pixel – iPhone 13/14)

* **AppBar**: top padding SafeArea + 12; giữa AppBar và Card đầu: 16.
* **Card cảm biến**:

  * Mỗi StatBlock: min-width 150, padding 16, gap icon–title 6, title–value 8.
* **Card điều khiển**:

  * PowerSwitchLarge: h=68; margin bottom 16.
  * ModeSegmented: h=44; segment gap 8.
  * ToggleRow: mỗi mục h=48.

---

# 8) Viết cho dev (Widget tree gợi ý)

```
Scaffold
 └─ CustomAppBar(title, StatusChip)
 └─ SingleChildScrollView(padding: 20-24)
     ├─ Row(StatCard °C, StatCard %)
     ├─ Card(Controls)
     │   ├─ PowerSwitchLarge
     │   ├─ ModeSegmented(1..3)
     │   └─ Row(Toggle: Rotate, Toggle: Auto)
     └─ Caption(lastUpdated)
 └─ FloatingActionButton(Voice)
 └─ VoiceAssistantSheet (modal)
```

---

# 9) Microcopy (chuẩn hoá)

* **Trạng thái**: “Hoạt động” / “Mất kết nối”
* **Hành động**: “Đã bật quạt”, “Đã tắt quạt”, “Đã chuyển tốc độ {n}”, “Đã bật xoay”, “Đã tắt xoay”, “Đã bật tự động”, “Đã tắt tự động”
* **Voice**: “Đang nghe…”, “Đang hiểu lệnh…”, “Đang thực thi…”, lỗi: “Tôi chưa hiểu. Bạn nói lại nhé.”

---

# 10) Kiểm thử & nghiệm thu (Checklist)

* [ ] Power/Mode/Rotate/Auto **≤ 2 chạm**
* [ ] Optimistic + rollback < 5s khi không có OK
* [ ] Online/Offline phản ánh đúng `lastSeen`
* [ ] Voice: giữ-để-nói → transcript → thực thi → TTS < 2.5s
* [ ] Dark mode: đơn sắc chuẩn (text/readability)
* [ ] Accessibility: target ≥44px; TalkBack đọc đúng label
* [ ] API Key: lưu secure; “Kiểm tra” hoạt động, báo lỗi rõ ràng

---

# 11) Tinh thần nghệ thuật (Neo-futurism “vũ trụ trắng”)

* **Không gian trắng** là “chất liệu” chính; nội dung như **khối tinh thể** nổi trên nền mù sương (`#F4F6F8`).
* **Ánh xanh băng** chỉ dùng như **tia laser** — tiết chế, không lạm dụng.
* **Chuyển động** tuyến tính, “đi tới tương lai”: mỗi thao tác như **đẩy một block** vào chuỗi (nhật ký).
* **Cảm xúc**: mát lạnh, sạch sẽ, kỹ trị — nhưng **ấm** nhờ haptic & giọng nói phản hồi tự nhiên.

---
