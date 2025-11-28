# Implementation Plan - Smart Fan Timer Functionality

This plan outlines the steps to implement a countdown timer (sleep timer) for the Smart Fan. The timer will be managed by the Node.js backend using an `expiresAt` timestamp to ensure synchronization across devices and resilience.

## User Review Required

> [!IMPORTANT]
> **Timer Logic Refined**:
> - **Synchronization**: The backend will calculate and store a timestamp (`expiresAt`) when the timer ends. The Frontend will calculate "remaining time" locally by comparing `expiresAt` with the current time.
> - **Conflict Resolution**: If the fan is manually turned **OFF**, the active timer will be **automatically cancelled**.
> - **Persistence**: `expiresAt` will be saved to the database. If the server restarts, it can theoretically recover (though strict recovery logic is a "nice to have", saving the state is the first step).

## Proposed Changes

### Backend (Node.js)

#### [NEW] [timerService.js](file:///e:/vmu/IOT/smart_fan/BE/src/services/timerService.js)
- Manage active timers using `Map<deviceId, { timeoutId, expiresAt }>`.
- `setTimer(deviceId, minutes, callback)`:
    - Calculate `expiresAt = Date.now() + minutes * 60000`.
    - Set `setTimeout` to trigger callback (turn off fan).
    - Store in Map.
    - Return `expiresAt`.
- `cancelTimer(deviceId)`: Clear timeout and remove from Map.
- `getTimer(deviceId)`: Return current `expiresAt`.

#### [MODIFY] [deviceController.js](file:///e:/vmu/IOT/smart_fan/BE/src/controllers/deviceController.js)
- **Handle `TIMER` command**:
    - Call `timerService.setTimer`.
    - Update `Device` DB: `state.reported.timerExpiresAt` & `state.desired.timerExpiresAt`.
    - Emit `device_update` with `timerExpiresAt`.
- **Handle `POWER` command**:
    - If `value == 'OFF'` (or boolean false), call `timerService.cancelTimer`.
    - Update `Device` DB: Set `timerExpiresAt` to `null`.
    - Emit `device_update` with `timerExpiresAt: null`.

#### [MODIFY] [Device.js](file:///e:/vmu/IOT/smart_fan/BE/src/models/Device.js)
- Add `timerExpiresAt: Date` to `state.reported` and `state.desired`.

### Frontend (Flutter)

#### [MODIFY] [fan_entity.dart](file:///e:/vmu/IOT/smart_fan/FE/lib/features/smart_fan/domain/entities/fan_entity.dart)
- Replace `int timer` with `final DateTime? timerExpiresAt;`.

#### [MODIFY] [fan_model.dart](file:///e:/vmu/IOT/smart_fan/FE/lib/features/smart_fan/data/models/fan_model.dart)
- Map `timerExpiresAt` from JSON string/timestamp.

#### [MODIFY] [fan_state.dart](file:///e:/vmu/IOT/smart_fan/FE/lib/models/fan_state.dart)
- Replace `timer` with `DateTime? timerExpiresAt`.

#### [MODIFY] [i_fan_repository.dart](file:///e:/vmu/IOT/smart_fan/FE/lib/features/smart_fan/domain/repositories/i_fan_repository.dart)
- Update `sendCommand` to accept `int? timerMinutes` (for setting) or specific command structure.

#### [MODIFY] [fan_provider.dart](file:///e:/vmu/IOT/smart_fan/FE/lib/providers/fan_provider.dart)
- Handle `timerExpiresAt` update from stream.
- `sendCommand('timer', minutes)`: Send duration to server.

#### [MODIFY] [smart_fan_screen.dart](file:///e:/vmu/IOT/smart_fan/FE/lib/features/smart_fan/presentation/screens/smart_fan_screen.dart)
- **UI Display**:
    - Use `Timer.periodic` (every 1s) to calculate `remaining = timerExpiresAt - now`.
    - Format as `HH:mm:ss`.
    - If `remaining <= 0`, hide timer UI.
- **Interaction**:
    - "Timer" button opens selection dialog.
    - Sending "0" or "Cancel" sends cancellation command.

## Verification Plan

### Manual Verification
1.  **Sync Test**:
    - Set timer (e.g., 60m) on App A.
    - Open App B (or restart App A).
    - Verify App B shows correct remaining time (e.g., 59:30) immediately.
2.  **Manual Override Test**:
    - Set timer 10m.
    - Turn Fan OFF manually.
    - Turn Fan ON.
    - Verify Timer is GONE (cancelled).
3.  **Countdown Execution**:
    - Set timer 1m.
    - Wait.
    - Verify Fan turns OFF and App updates.
