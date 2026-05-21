const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electron', {
  heap: {
    read: (offset, length) => ipcRenderer.invoke('heap:read', offset, length),
    write: (offset, buffer) => ipcRenderer.invoke('heap:write', offset, buffer)
  },
  system: {
    getPlatform: () => process.platform,
    getMemoryInfo: () => process.getSystemMemoryInfo()
  }
});
