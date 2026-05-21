const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const fs = require('fs');

// Load the Janus Heap Native Addon
let janusHeap;
try {
  const addonPath = path.join(__dirname, '../build/Release/janus_heap.node');
  if (fs.existsSync(addonPath)) {
    janusHeap = require(addonPath);
    console.log('Janus: Native Heap Addon loaded.');
  }
} catch (e) {
  console.error('Janus: Failed to load native heap addon:', e);
}

function createWindow() {
  const win = new BrowserWindow({
    width: 1200,
    height: 800,
    transparent: true,
    frame: false,
    hasShadow: false,
    alwaysOnTop: true,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true
    }
  });

  // In development, load from Vite
  win.loadURL('http://localhost:5173');
  
  // Set always on top to maintain the "Hijack" feel
  win.setAlwaysOnTop(true, 'screen-saver');

  // Attempt to map the Janus Monolith if addon is available
  if (janusHeap) {
    try {
      // 64GB default capacity from JanusHeap.swift
      const capacityBytes = 64 * 1024 * 1024 * 1024;
      const success = janusHeap.mapHeap('/janus_monolith', capacityBytes);
      if (success) {
        console.log('Janus: Successfully mapped 64GB Shared Monolith in Electron.');
      }
    } catch (e) {
      console.warn('Janus: Could not map heap (perhaps Swift engine is not running):', e.message);
    }
  }
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});

// IPC handlers for UI to interact with the Monolith
ipcMain.handle('heap:read', async (event, offset, length) => {
  if (!janusHeap) return null;
  return janusHeap.readBuffer(offset, length);
});

ipcMain.handle('heap:write', async (event, offset, buffer) => {
  if (!janusHeap) return false;
  janusHeap.writeBuffer(offset, buffer);
  return true;
});
