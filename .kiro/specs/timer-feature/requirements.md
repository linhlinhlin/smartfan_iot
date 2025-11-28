# Requirements Document

## Introduction

Chức năng hẹn giờ (Timer/Sleep Timer) cho phép người dùng đặt thời gian tự động tắt quạt sau một khoảng thời gian nhất định. Timer được quản lý bởi backend sử dụng timestamp `expiresAt` để đảm bảo đồng bộ giữa các thiết bị và khả năng phục hồi khi server restart.

## Glossary

- **Timer**: Bộ đếm ngược thời gian để tự động tắt quạt
- **expiresAt**: Timestamp (UTC) đánh dấu thời điểm timer hết hạn và quạt sẽ tắt
- **Backend**: Server Node.js xử lý logic timer và giao tiếp MQTT
- **Frontend**: Ứng dụng Flutter hiển thị và điều khiển timer
- **Device Shadow**: Trạng thái thiết bị được lưu trong MongoDB (reported/desired state)

## Requirements

### Requirement 1

**User Story:** As a user, I want to set a countdown timer for the fan, so that the fan automatically turns off after a specified duration.

#### Acceptance Criteria

1. WHEN a user selects a timer duration (e.g., 30 minutes, 1 hour, 2 hours) THEN the System SHALL calculate `expiresAt = currentTime + duration` and store it in the database
2. WHEN a timer is set THEN the System SHALL display the remaining countdown time on the app in `HH:mm:ss` format
3. WHEN the timer reaches zero THEN the System SHALL automatically turn off the fan and send the POWER OFF command via MQTT
4. WHEN a timer is active THEN the System SHALL update the countdown display every second on the frontend

### Requirement 2

**User Story:** As a user, I want to cancel an active timer, so that I can keep the fan running without automatic shutoff.

#### Acceptance Criteria

1. WHEN a user cancels an active timer THEN the System SHALL clear the `expiresAt` value and stop the countdown
2. WHEN a timer is cancelled THEN the System SHALL emit a `device_update` event with `timerExpiresAt: null` to all connected clients

### Requirement 3

**User Story:** As a user, I want the timer to be cancelled when I manually turn off the fan, so that I don't have unexpected behavior when I turn the fan back on.

#### Acceptance Criteria

1. WHEN a user manually turns off the fan while a timer is active THEN the System SHALL automatically cancel the timer
2. WHEN the fan is turned back on after manual shutoff THEN the System SHALL start with no active timer

### Requirement 4

**User Story:** As a user, I want to see the same timer countdown on multiple devices, so that I can check the remaining time from any device.

#### Acceptance Criteria

1. WHEN a timer is set from Device A THEN Device B SHALL display the same remaining time when opened
2. WHEN calculating remaining time THEN the Frontend SHALL compute `remaining = expiresAt - currentTime` locally using the stored `expiresAt` timestamp
3. WHEN exchanging timer data THEN the System SHALL use UTC timestamp format to handle timezone differences correctly

### Requirement 5

**User Story:** As a system administrator, I want active timers to be restored after server restart, so that users don't lose their timer settings.

#### Acceptance Criteria

1. WHEN the server starts THEN the System SHALL query the database for devices with `timerExpiresAt > currentTime`
2. WHEN an active timer is found in the database THEN the System SHALL restore the `setTimeout` with the remaining duration
3. WHEN restoring timers THEN the System SHALL log the restoration action for debugging purposes

### Requirement 6

**User Story:** As a developer, I want the timer UI to be properly cleaned up when the user leaves the screen, so that there are no memory leaks or crashes.

#### Acceptance Criteria

1. WHEN the user navigates away from the fan control screen THEN the Frontend SHALL cancel the periodic UI timer
2. WHEN the timer widget is disposed THEN the Frontend SHALL release all timer resources to prevent memory leaks
