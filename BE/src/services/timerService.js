/**
 * TimerService - Manages active timers for smart fan devices
 * 
 * Uses timestamp-based (expiresAt) approach for:
 * - Multi-device synchronization
 * - Server restart recovery
 * 
 * Requirements: 1.1, 2.1, 5.2
 */

class TimerService {
    constructor() {
        // Active timers storage: Map<deviceId, { timeoutId, expiresAt }>
        this.activeTimers = new Map();
    }

    /**
     * Set a new timer for a device
     * @param {string} deviceId - The device identifier
     * @param {number} minutes - Duration in minutes (1-1440)
     * @param {Function} callback - Function to call when timer expires
     * @returns {Date} The calculated expiresAt timestamp
     * @throws {Error} If duration is invalid
     */
    setTimer(deviceId, minutes, callback) {
        // Validate duration (1 minute to 24 hours)
        if (!Number.isInteger(minutes) || minutes < 1 || minutes > 1440) {
            throw new Error('Invalid timer duration. Must be between 1 and 1440 minutes.');
        }

        // Cancel existing timer if any
        this.cancelTimer(deviceId);

        // Calculate expiresAt = currentTime + duration
        const durationMs = minutes * 60 * 1000;
        const expiresAt = new Date(Date.now() + durationMs);

        // Create setTimeout
        console.log(`[TimerService] Creating setTimeout for ${durationMs}ms (${minutes} minutes)`);
        const timeoutId = setTimeout(() => {
            console.log(`[TimerService] ⏰ Timer expired for device: ${deviceId}`);
            this.activeTimers.delete(deviceId);
            if (typeof callback === 'function') {
                console.log(`[TimerService] Executing callback to turn off fan...`);
                callback();
            } else {
                console.log(`[TimerService] WARNING: No callback provided!`);
            }
        }, durationMs);

        // Store in Map
        this.activeTimers.set(deviceId, {
            timeoutId,
            expiresAt
        });

        console.log(`[TimerService] Timer set for device: ${deviceId}, expires at: ${expiresAt.toISOString()}`);
        return expiresAt;
    }

    /**
     * Cancel an active timer for a device
     * @param {string} deviceId - The device identifier
     * @returns {boolean} True if timer was cancelled, false if no timer existed
     */
    cancelTimer(deviceId) {
        const timer = this.activeTimers.get(deviceId);
        
        if (timer) {
            clearTimeout(timer.timeoutId);
            this.activeTimers.delete(deviceId);
            console.log(`[TimerService] ❌ Timer cancelled for device: ${deviceId}`);
            // Log stack trace to see who cancelled
            console.log(`[TimerService] Cancel called from:`, new Error().stack.split('\n').slice(2, 5).join('\n'));
            return true;
        }
        
        return false;
    }

    /**
     * Get current timer info for a device
     * @param {string} deviceId - The device identifier
     * @returns {{ expiresAt: Date } | null} Timer info or null if no active timer
     */
    getTimer(deviceId) {
        const timer = this.activeTimers.get(deviceId);
        
        if (timer) {
            return { expiresAt: timer.expiresAt };
        }
        
        return null;
    }

    /**
     * Restore a timer from database (for server restart recovery)
     * @param {string} deviceId - The device identifier
     * @param {Date} expiresAt - The stored expiration timestamp
     * @param {Function} callback - Function to call when timer expires
     * @returns {boolean} True if timer was restored, false if already expired
     */
    restoreTimer(deviceId, expiresAt, callback) {
        // Ensure expiresAt is a Date object
        const expireDate = expiresAt instanceof Date ? expiresAt : new Date(expiresAt);
        const remainingMs = expireDate.getTime() - Date.now();

        // Don't restore if already expired
        if (remainingMs <= 0) {
            console.log(`[TimerService] Timer already expired for device: ${deviceId}, skipping restoration`);
            return false;
        }

        // Cancel existing timer if any
        this.cancelTimer(deviceId);

        // Create setTimeout with remaining time
        const timeoutId = setTimeout(() => {
            console.log(`[TimerService] Restored timer expired for device: ${deviceId}`);
            this.activeTimers.delete(deviceId);
            if (typeof callback === 'function') {
                callback();
            }
        }, remainingMs);

        // Store in Map
        this.activeTimers.set(deviceId, {
            timeoutId,
            expiresAt: expireDate
        });

        const remainingMinutes = Math.ceil(remainingMs / 60000);
        console.log(`[TimerService] Timer restored for device: ${deviceId}, remaining: ${remainingMinutes} minutes`);
        return true;
    }

    /**
     * Get all active timers (for debugging/monitoring)
     * @returns {Array<{ deviceId: string, expiresAt: Date }>}
     */
    getAllTimers() {
        const timers = [];
        this.activeTimers.forEach((timer, deviceId) => {
            timers.push({ deviceId, expiresAt: timer.expiresAt });
        });
        return timers;
    }
}

// Export singleton instance
module.exports = new TimerService();
