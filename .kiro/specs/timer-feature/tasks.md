# Implementation Plan - Timer Feature

- [x] 1. Backend: Create TimerService





  - [x] 1.1 Create `BE/src/services/timerService.js` with Map storage for active timers


    - Implement `setTimer(deviceId, minutes, callback)` function
    - Implement `cancelTimer(deviceId)` function
    - Implement `getTimer(deviceId)` function
    - Implement `restoreTimer(deviceId, expiresAt, callback)` function
    - _Requirements: 1.1, 2.1, 5.2_

- [x] 2. Backend: Update Device Model





  - [x] 2.1 Add `timerExpiresAt` field to Device schema


    - Add to `state.reported.timerExpiresAt: Date`
    - Add to `state.desired.timerExpiresAt: Date`
    - _Requirements: 1.1, 4.3_

- [x] 3. Backend: Update DeviceController








  - [x] 3.1 Handle TIMER command in `sendCommand` function

    - If value > 0: call timerService.setTimer, update DB, emit socket event
    - If value == 0: call timerService.cancelTimer, clear DB, emit socket event
    - _Requirements: 1.1, 1.3, 2.1, 2.2_

  - [x] 3.2 Update POWER command to cancel timer when turning off
    - Call timerService.cancelTimer when value == 0
    - Clear timerExpiresAt in DB
    - _Requirements: 3.1, 3.2_

- [x] 4. Backend: Implement Timer Restoration (QUAN TRỌNG)





  - [x] 4.1 Create `restoreActiveTimers()` function in `BE/src/index.js`


    - Query DB for devices with timerExpiresAt > now
    - Calculate remaining time and restore setTimeout
    - Log restoration actions
    - _Requirements: 5.1, 5.2, 5.3_
  - [x] 4.2 Call `restoreActiveTimers()` after DB connection


    - _Requirements: 5.1_

- [x] 5. Backend: Update MQTT Subscriber






  - [x] 5.1 Include `timerExpiresAt` in device_update socket emission

    - Map timerExpiresAt from DB to socket event
    - _Requirements: 4.1_

- [x] 6. Checkpoint - Backend Manual Test

  - Test API với Postman/Log để verify:
    - Set timer → check DB có timerExpiresAt
    - Cancel timer → check DB cleared
    - Power OFF → check timer cancelled
    - Server restart → check timer restored

- [x] 7. Frontend: Update Data Models










  - [x] 7.1 Add `timerExpiresAt` to FanEntity

    - Add `final DateTime? timerExpiresAt` field
    - _Requirements: 1.2, 4.2_
  - [x] 7.2 Update FanModel to parse timerExpiresAt from JSON


    - Parse ISO 8601 string to DateTime
    - Handle null values
    - _Requirements: 4.3_
  - [x] 7.3 Add `timerExpiresAt` to FanState with formatting helper


    - Add `DateTime? timerExpiresAt` field
    - Add `String? get formattedRemainingTime` getter
    - _Requirements: 1.2_

- [x] 8. Frontend: Update Repository and Provider





  - [x] 8.1 Update IFanRepository to support timer command


    - Add `timerMinutes` parameter to sendCommand
    - _Requirements: 1.1_
  - [x] 8.2 Update FanRepository implementation


    - Send TIMER command with minutes value
    - _Requirements: 1.1_
  - [x] 8.3 Update FanProvider to handle timerExpiresAt


    - Update state from stream with timerExpiresAt
    - Add `sendTimerCommand(int minutes)` method
    - _Requirements: 1.1, 2.1_

- [x] 9. Frontend: Create Timer UI Components





  - [x] 9.1 Create TimerSelector widget (đơn giản trước)


    - Display preset options (30min, 1h, 2h, 4h, 8h)
    - Show current timer status
    - Cancel button when timer is active
    - _Requirements: 1.1, 2.1_
  - [x] 9.2 Create TimerDisplay widget


    - Show countdown in HH:mm:ss format
    - Use Timer.periodic for 1-second updates
    - Handle dispose to prevent memory leaks
    - _Requirements: 1.2, 1.4, 6.1, 6.2_

- [x] 10. Frontend: Integrate Timer into Dashboard





  - [x] 10.1 Add timer section to DashboardScreen


    - Show TimerDisplay when timer is active
    - Add button to open TimerSelector dialog
    - _Requirements: 1.2, 1.4_
  - [x] 10.2 Handle timer state updates from provider


    - Update UI when timerExpiresAt changes
    - _Requirements: 4.1_

- [x] 11. Checkpoint - Frontend Manual Test




  - Test trên app để verify UI hoạt động đúng

- [ ]* 12. Integration Tests (DEFERRED - Làm sau khi hệ thống chạy mượt)
  - [ ]* 12.1 Write end-to-end timer flow test
    - Set timer → verify DB → wait → verify fan off
    - _Requirements: 1.1, 1.3_
  - [ ]* 12.2 Write multi-client sync test
    - Set timer from client A → verify client B receives same expiresAt
    - _Requirements: 4.1, 4.2_

- [ ] 13. Final Manual Verification
  - **Sync Test**: Set timer App A → Open App B → Verify same remaining time
  - **Override Test**: Set timer → Turn OFF manually → Turn ON → Verify timer GONE
  - **Execution Test**: Set timer 1 min → Wait → Verify fan turns OFF
