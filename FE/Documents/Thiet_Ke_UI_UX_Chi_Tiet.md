# Thiết Kế UI/UX Chi Tiết - Quạt Thông Minh

## Tổng Quan Thiết Kế

**Phong cách**: Neo-futurism × Blockchain ẩn dụ × Vũ trụ trắng
**Ngôn ngữ**: Tiếng Việt
**Nền tảng**: Flutter Material 3
**Thiết bị mục tiêu**: Smartphone Android/iOS

---

## 1. Hệ Thống Màu Sắc (Color System)

### Vũ Trụ Trắng - Cosmic White Universe
```dart
// Màu chính - Primary Colors
cosmicWhite: #FFFFFFFF     // Trắng vũ trụ tinh khiết
nebulaMist: #FFF8F9FA      // Sương mù tinh vân nhẹ
starfield: #FFF4F6F8       // Bầu trời sao nền
cosmicDust: #FFE8ECF0      // Bụi vũ trụ

// Màu công nghệ - Tech Colors
techRay: #FF8AD5FF         // Tia công nghệ xanh băng
quantumBlue: #FF00BCD4     // Xanh lượng tử
plasmaGlow: #FF9C27B0      // Ánh sáng plasma tím

// Màu trạng thái - Status Colors
graphite700: #FF2A2F36    // Than chì vũ trụ
graphite500: #FF5A6472    // Than chì tinh vân
success: #FF21C274         // Thành công xanh
warning: #FFFFB020         // Cảnh báo vàng
error: #FFF55555           // Lỗi đỏ
voidBlack: #FF0A0A0A      // Đen không gian sâu
```

### Nguyên Tắc Áp Dụng
- **Vũ trụ trắng làm nền tảng**: 95% giao diện sử dụng các tông trắng tinh vân
- **Công nghệ làm điểm nhấn**: Chỉ sử dụng màu tech khi cần nhấn mạnh tương tác
- **Blockchain ẩn dụ**: Tia sáng và hiệu ứng điện đại diện cho luồng dữ liệu

---

## 2. Typography (Hệ Thống Chữ)

### Font Family
- **Primary**: Inter (Modern, Tech-forward)
- **Fallback**: SF Pro Display

### Scale Hierarchy
```dart
Display Large: 48px, 600w, graphite700    // Số liệu lớn
Display Medium: 40px, 600w, graphite700   // Tiêu đề chính
Title Large: 22px, 600w, graphite700      // App bar
Title Medium: 18px, 600w, graphite700     // Card headers
Body Large: 16px, 400w, graphite700       // Nội dung chính
Body Medium: 14px, 400w, graphite700      // Mô tả
Label Medium: 12px, 500w, graphite500     // Nhãn phụ
```

---

## 3. Spacing & Layout (Khoảng Cách & Bố Cục)

### Grid System
- **Base Unit**: 8px (8pt grid)
- **Spacing Scale**: 8, 12, 16, 20, 24, 32, 40, 48px

### Screen Layout
```dart
Screen Padding: 20px all sides
Card Padding: 16-20px internal
Element Spacing: 12-16px between elements
Section Spacing: 24-32px between sections
```

---

## 4. Component Design (Thiết Kế Thành Phần)

### 4.1 Cosmic Background (Nền Vũ Trụ)

**Mục đích**: Tạo cảm giác không gian vũ trụ tinh tế
**Thành phần**:
- Gradient 3 lớp: cosmicWhite → nebulaMist → starfield
- 12 hạt bụi vũ trụ ngẫu nhiên (opacity 0.03-0.08)
- Tia sáng công nghệ xuất hiện ngẫu nhiên (opacity 0.01-0.03)

**Animation**: 20s drift cho particles, 8s pulse cho rays

### 4.2 Status Chip (Thẻ Trạng Thái)

**Kích thước**: 28-30px height, padding 10-12px horizontal
**Design**:
- Online: background rgba(33,194,116,0.12), dot xanh lá, text "Hoạt động"
- Offline: background rgba(0,0,0,0.06), dot xám, text "Mất kết nối"
- Border radius: 12px
- Font: 12px, 500w

### 4.3 Stat Card (Thẻ Thống Kê Cảm Biến)

**Layout**: 2 cột ngang trên màn hình lớn, xếp dọc trên nhỏ
**Anatomy**:
```
┌─────────────────────────────────┐
│ 🌡 Icon (24px)  Nhiệt độ         │
│                                  │
│         26.3°         °C         │
│     Display 40px    Title 18px  │
│                                  │
│        Cập nhật 10s trước       │
│        Body Small 12px          │
└─────────────────────────────────┘
```

**Styling**:
- Card radius: 16px
- Border: 1px rgba(0,0,0,0.06)
- Elevation: 2 (subtle shadow)
- Padding: 16px

### 4.4 Hero Power Button (Nút Nguồn Chính)

**Kích thước**: 140px diameter (hero element)
**Layers**:
1. **Outer Glow**: Gradient ice-blue with blur 20px
2. **Main Body**: Circular gradient (ice-blue → teal)
3. **Inner Circle**: White with subtle border
4. **Fan Icon**: AcUnit icon 48px with rotation animation
5. **Power Indicator**: Green dot top-right
6. **Speed Badge**: White badge bottom when active

**Animations**:
- **Rotation**: Based on speed (0=stop, 1-3=different speeds)
- **Lightning Arcs**: 3 radial arcs when activating
- **3D Press**: Scale 0.95 on tap
- **Glow Pulse**: Ice-blue glow when active

### 4.5 Mode Segmented Control (Điều Khiển Chế Độ)

**Design**: 3 equal segments in horizontal pill
**States**:
- **Normal**: White background, graphite text
- **Selected**: Ice-blue glow (opacity 0.1), techRay text, subtle shadow
- **Disabled**: 0.6 opacity, no interaction

**Animation**: 150ms ease transition

### 4.6 Toggle Row (Hàng Chuyển Đổi)

**Layout**: Label left, Switch right
**Styling**:
- Label: Body Medium 14px, 500w
- Switch: Material 3 design with custom colors
- Active: techRay thumb, 0.3 opacity track
- Spacing: 16px between label and switch

---

## 5. Screen Layouts (Bố Cục Màn Hình)

### 5.1 Dashboard Screen (Màn Chính)

```
┌─ AppBar ──────────────────────────────┐
│ Quạt Phòng Khách          [● Online] │
├───────────────────────────────────────┤
│                                       │
│  🌡 26.3°C     💧 55%               │
│  Nhiệt độ       Độ ẩm                │
│                                       │
├───────────────────────────────────────┤
│                                       │
│         ⚡ HERO POWER BUTTON ⚡       │
│                                       │
│    Large Circular Button 140px        │
│    with 3D Effects & Animations       │
│                                       │
│         Quạt đang hoạt động          │
│                                       │
├───────────────────────────────────────┤
│  Điều khiển nâng cao                  │
│                                       │
│  Tốc độ: [1] [2] [3]                 │
│                                       │
│  ↻ Xoay          [ON]                │
│  A Tự động       [OFF]               │
│                                       │
├───────────────────────────────────────┤
│       Cập nhật 10 giây trước         │
└───────────────────────────────────────┘
    ◉ (Voice FAB)
```

**Visual Hierarchy**:
1. **Hero Element**: Power button (most prominent)
2. **Primary Info**: Sensor data (large, easy to scan)
3. **Secondary**: Advanced controls (compact)
4. **Status**: Connection and update info (subtle)

### 5.2 Login Screen (Màn Đăng Nhập)

```
┌─ AppBar ──────────────────────────────┐
│            Đăng nhập                 │
├───────────────────────────────────────┤
│                                       │
│        [Fan Icon Placeholder]         │
│                                       │
│             Chào mừng                │
│                                       │
│  ┌─────────────────────────────────┐  │
│  │ Đăng nhập ẩn danh              │  │
│  └─────────────────────────────────┘  │
│                                       │
│                 hoặc                   │
│                                       │
│  Email: [_______________________]    │
│  Mật khẩu: [____________________]    │
│                                       │
│  ┌─────────────────────────────────┐  │
│  │ Đăng nhập                       │  │
│  └─────────────────────────────────┘  │
│                                       │
│  Version 1.0.0                        │
│  Chính sách quyền riêng tư            │
└───────────────────────────────────────┘
```

---

## 6. Animation & Motion (Hoạt Hình & Chuyển Động)

### 6.1 Micro-interactions
- **Button Press**: 150ms scale 0.95 → 1.0
- **State Changes**: 220ms linear ease
- **Loading**: Circular progress with fade
- **Success Feedback**: 500ms green highlight

### 6.2 Continuous Animations
- **Fan Rotation**: Speed-based (4s, 3s, 2s cycles)
- **Cosmic Particles**: 20s gentle drift
- **Tech Rays**: 8s subtle pulse
- **Lightning Arcs**: 800ms activation effect

### 6.3 Page Transitions
- **Fade Through**: 300ms with staggered elements
- **Shared Element**: Hero button zoom transition

---

## 7. Accessibility (Khả Năng Tiếp Cận)

### Touch Targets
- **Minimum**: 44px for all interactive elements
- **Preferred**: 48px+ for primary actions

### Color Contrast
- **Primary Text**: 4.5:1 ratio (graphite700 on cosmicWhite)
- **Secondary Text**: 4.5:1 ratio (graphite500 on backgrounds)

### Screen Reader Support
- **Semantic Labels**: All icons have descriptive labels
- **State Announcements**: Status changes announced
- **Focus Indicators**: Clear focus rings for keyboard navigation

---

## 8. Responsive Design (Thiết Kế Phản Ứng)

### Breakpoints
- **Mobile**: < 600px (primary target)
- **Tablet**: 600-1200px (supported)
- **Desktop**: > 1200px (future consideration)

### Adaptive Layout
- **Sensor Cards**: 2-column on mobile/tablet, 1-column on small screens
- **Controls**: Stack vertically on narrow screens
- **Hero Button**: Maintains size, adjusts spacing

---

## 9. Dark Mode Considerations (Cân Nhắc Chế Độ Tối)

### Color Mapping
- **cosmicWhite** → **voidBlack**
- **nebulaMist** → **cosmicDust**
- **techRay** → **plasmaGlow** (enhanced)
- **graphite700** → **cosmicWhite**

### Preserved Elements
- **Cosmic particles**: Become brighter stars
- **Tech rays**: More prominent in dark space
- **Hero button**: Maintains glow effects

---

## 10. Performance Optimizations (Tối Ưu Hiệu Suất)

### Animation Performance
- **GPU Acceleration**: Transform and opacity animations
- **60fps Target**: All animations optimized
- **Battery Conscious**: Reduced animations on low power

### Memory Management
- **Asset Optimization**: Compressed images
- **Widget Reuse**: Efficient component recycling
- **State Management**: Provider with proper disposal

---

## 11. Testing Guidelines (Hướng Dẫn Kiểm Thử)

### Visual Testing
- **Color Contrast**: Verify 4.5:1 ratios
- **Touch Targets**: 44px minimum verified
- **Layout Consistency**: Grid alignment checked

### Interaction Testing
- **Animation Timing**: 60fps maintained
- **State Transitions**: Smooth without jank
- **Loading States**: Proper feedback provided

### Accessibility Testing
- **Screen Reader**: All elements labeled
- **Keyboard Navigation**: Full support
- **Color Blind**: Sufficient contrast without color dependence