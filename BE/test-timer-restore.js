/**
 * Timer Restoration Test Script
 * 
 * Tests that timers are properly restored after server restart.
 * Run with: node test-timer-restore.js
 */

require('dotenv').config();
const mongoose = require('mongoose');

const DEVICE_ID = 'FAN001';

async function testTimerRestoration() {
    console.log('='.repeat(60));
    console.log('TIMER RESTORATION TEST');
    console.log('='.repeat(60));
    
    // Connect to MongoDB
    console.log('\n[Setup] Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGO_URI);
    console.log('[Setup] ✓ Connected to MongoDB');
    
    const Device = require('./src/models/Device');
    const timerService = require('./src/services/timerService');
    
    try {
        // Check current DB state
        const device = await Device.findOne({ deviceId: DEVICE_ID });
        const timerExpiresAt = device?.state?.reported?.timerExpiresAt;
        
        console.log('\n[DB Check] Current timer state:');
        console.log('  timerExpiresAt:', timerExpiresAt?.toISOString() || 'null');
        
        if (timerExpiresAt) {
            const remainingMs = timerExpiresAt.getTime() - Date.now();
            const remainingMin = Math.ceil(remainingMs / 60000);
            console.log('  Remaining time:', remainingMin, 'minutes');
            console.log('  Timer is:', remainingMs > 0 ? 'ACTIVE' : 'EXPIRED');
            
            if (remainingMs > 0) {
                // Test restoration
                console.log('\n[Test] Simulating timer restoration...');
                
                const restored = timerService.restoreTimer(DEVICE_ID, timerExpiresAt, () => {
                    console.log('[Callback] Timer would turn off fan here');
                });
                
                if (restored) {
                    console.log('✓ Timer successfully restored!');
                    
                    // Verify it's in the service
                    const timerInfo = timerService.getTimer(DEVICE_ID);
                    console.log('  Service timer info:', timerInfo);
                    
                    // Cancel it to clean up
                    timerService.cancelTimer(DEVICE_ID);
                    console.log('  (Timer cancelled for cleanup)');
                } else {
                    console.log('✗ Timer restoration failed');
                }
            }
        } else {
            console.log('\n[Info] No active timer found in DB.');
            console.log('To test restoration:');
            console.log('1. Run: node test-timer.js (to set a timer)');
            console.log('2. Then run this script again');
        }
        
    } catch (error) {
        console.error('Error:', error.message);
    } finally {
        await mongoose.disconnect();
        console.log('\n[Cleanup] Disconnected from MongoDB');
    }
}

testTimerRestoration().catch(console.error);
