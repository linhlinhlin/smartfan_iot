/**
 * Timer Feature Manual Test Script
 * 
 * This script tests the timer functionality by making API calls
 * and checking the database state.
 * 
 * Run with: node test-timer.js
 */

require('dotenv').config();
const mongoose = require('mongoose');

const DEVICE_ID = 'FAN001'; // Test device ID
const BASE_URL = `http://localhost:${process.env.PORT || 3000}`;

async function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function makeRequest(endpoint, method = 'GET', body = null) {
    const options = {
        method,
        headers: { 'Content-Type': 'application/json' }
    };
    if (body) options.body = JSON.stringify(body);
    
    const response = await fetch(`${BASE_URL}${endpoint}`, options);
    return response.json();
}

async function checkDB(deviceId) {
    const Device = require('./src/models/Device');
    const device = await Device.findOne({ deviceId });
    return {
        timerExpiresAt: device?.state?.reported?.timerExpiresAt,
        isOn: device?.state?.reported?.isOn
    };
}

async function runTests() {
    console.log('='.repeat(60));
    console.log('TIMER FEATURE - MANUAL TEST SCRIPT');
    console.log('='.repeat(60));
    
    // Connect to MongoDB
    console.log('\n[Setup] Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGO_URI);
    console.log('[Setup] ✓ Connected to MongoDB');
    
    try {
        // Test 1: Set Timer
        console.log('\n' + '-'.repeat(60));
        console.log('TEST 1: Set Timer (1 minute)');
        console.log('-'.repeat(60));
        
        const setResult = await makeRequest(
            `/api/devices/${DEVICE_ID}/command`,
            'POST',
            { command: 'TIMER', value: 1 }
        );
        console.log('API Response:', JSON.stringify(setResult, null, 2));
        
        await sleep(500); // Wait for DB update
        const dbAfterSet = await checkDB(DEVICE_ID);
        console.log('DB State:', {
            timerExpiresAt: dbAfterSet.timerExpiresAt?.toISOString() || null,
            hasTimer: !!dbAfterSet.timerExpiresAt
        });
        
        if (dbAfterSet.timerExpiresAt) {
            console.log('✓ TEST 1 PASSED: Timer set in DB');
        } else {
            console.log('✗ TEST 1 FAILED: timerExpiresAt not found in DB');
        }
        
        // Test 2: Cancel Timer
        console.log('\n' + '-'.repeat(60));
        console.log('TEST 2: Cancel Timer');
        console.log('-'.repeat(60));
        
        const cancelResult = await makeRequest(
            `/api/devices/${DEVICE_ID}/command`,
            'POST',
            { command: 'TIMER', value: 0 }
        );
        console.log('API Response:', JSON.stringify(cancelResult, null, 2));
        
        await sleep(500);
        const dbAfterCancel = await checkDB(DEVICE_ID);
        console.log('DB State:', {
            timerExpiresAt: dbAfterCancel.timerExpiresAt?.toISOString() || null,
            hasTimer: !!dbAfterCancel.timerExpiresAt
        });
        
        if (!dbAfterCancel.timerExpiresAt) {
            console.log('✓ TEST 2 PASSED: Timer cleared from DB');
        } else {
            console.log('✗ TEST 2 FAILED: timerExpiresAt still exists in DB');
        }
        
        // Test 3: Power OFF cancels timer
        console.log('\n' + '-'.repeat(60));
        console.log('TEST 3: Power OFF cancels active timer');
        console.log('-'.repeat(60));
        
        // First set a timer
        console.log('Step 1: Setting timer...');
        await makeRequest(
            `/api/devices/${DEVICE_ID}/command`,
            'POST',
            { command: 'TIMER', value: 5 }
        );
        await sleep(500);
        
        const dbBeforePowerOff = await checkDB(DEVICE_ID);
        console.log('Timer set:', !!dbBeforePowerOff.timerExpiresAt);
        
        // Then turn off power
        console.log('Step 2: Sending POWER OFF...');
        const powerOffResult = await makeRequest(
            `/api/devices/${DEVICE_ID}/command`,
            'POST',
            { command: 'POWER', value: 0 }
        );
        console.log('API Response:', JSON.stringify(powerOffResult, null, 2));
        
        await sleep(500);
        const dbAfterPowerOff = await checkDB(DEVICE_ID);
        console.log('DB State after POWER OFF:', {
            timerExpiresAt: dbAfterPowerOff.timerExpiresAt?.toISOString() || null,
            hasTimer: !!dbAfterPowerOff.timerExpiresAt
        });
        
        if (!dbAfterPowerOff.timerExpiresAt) {
            console.log('✓ TEST 3 PASSED: Timer cancelled when power turned off');
        } else {
            console.log('✗ TEST 3 FAILED: Timer still exists after power off');
        }
        
        // Test 4: Get device state includes timer
        console.log('\n' + '-'.repeat(60));
        console.log('TEST 4: Get Device State API');
        console.log('-'.repeat(60));
        
        // Set a timer first
        await makeRequest(
            `/api/devices/${DEVICE_ID}/command`,
            'POST',
            { command: 'TIMER', value: 10 }
        );
        await sleep(500);
        
        const stateResult = await makeRequest(`/api/devices/${DEVICE_ID}/state`);
        console.log('Device State:', JSON.stringify(stateResult, null, 2));
        
        if (stateResult.timerExpiresAt) {
            console.log('✓ TEST 4 PASSED: timerExpiresAt included in state response');
        } else {
            console.log('⚠ TEST 4 NOTE: timerExpiresAt may not be in state response (check implementation)');
        }
        
        // Cleanup
        console.log('\n[Cleanup] Cancelling test timer...');
        await makeRequest(
            `/api/devices/${DEVICE_ID}/command`,
            'POST',
            { command: 'TIMER', value: 0 }
        );
        
        // Summary
        console.log('\n' + '='.repeat(60));
        console.log('TEST SUMMARY');
        console.log('='.repeat(60));
        console.log('Test 1 (Set Timer): Check logs above');
        console.log('Test 2 (Cancel Timer): Check logs above');
        console.log('Test 3 (Power OFF cancels timer): Check logs above');
        console.log('Test 4 (Get State): Check logs above');
        console.log('\nFor Test 5 (Server Restart):');
        console.log('1. Set a timer: POST /api/devices/FAN001/command {command:"TIMER",value:5}');
        console.log('2. Restart the server (Ctrl+C then npm start)');
        console.log('3. Check server logs for "[TimerRestore]" messages');
        console.log('='.repeat(60));
        
    } catch (error) {
        console.error('Test Error:', error.message);
    } finally {
        await mongoose.disconnect();
        console.log('\n[Cleanup] Disconnected from MongoDB');
    }
}

// Run tests
runTests().catch(console.error);
