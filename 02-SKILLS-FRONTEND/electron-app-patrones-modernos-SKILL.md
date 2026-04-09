---
name: "Electron App - Patrones Modernos"
description: "Guía completa sobre arquitectura moderna de Electron, seguridad, build tools (esbuild, Vite), IPC, electron-updater y distribución multiplataforma con Electron Forge"
triggers:
  - "patrones modernos electron"
  - "electron architecture"
  - "electron forge"
  - "electron seguridad"
  - "electron ipc"
  - "electron vite"
---

# Electron App - Patrones Modernos de Desarrollo

## 1. Arquitectura Fundamental de Electron

### Procesos en Electron

Electron divide la aplicación en dos procesos principales:

- **Main Process**: Ejecuta en Node.js, controla ciclo de vida, crea ventanas, accede a sistema operativo
- **Renderer Process**: Ejecuta en Chromium, contiene la UI (HTML/CSS/JS)
- **Preload Scripts**: Puente seguro entre Main y Renderer, carga antes que el contenido de la página

### Modelo de Seguridad Moderno

```
┌─────────────────────────────────┐
│     Renderer Process (UI)       │
│   (sandbox=true, aislado)       │
└────────────────┬────────────────┘
                 │
        ┌────────▼─────────┐
        │  Preload Script   │
        │ (contextBridge)   │
        └────────┬─────────┘
                 │ IPC seguro
┌────────────────▼─────────────────┐
│     Main Process (Node.js)       │
│   (acceso sistema completo)      │
└─────────────────────────────────┘
```

## 2. Preload Script con contextBridge

Patrón seguro para exponer APIs del sistema:

```javascript
// src/preload.ts
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  // APIs síncronas con validación
  getAppVersion: () => process.env.REACT_APP_VERSION,
  
  // APIs asincrónicas vía IPC
  readFile: (filePath) => 
    ipcRenderer.invoke('file:read', filePath),
  
  saveFile: (content, filePath) => 
    ipcRenderer.invoke('file:save', { content, filePath }),
  
  onFileSystemChange: (callback) => {
    ipcRenderer.on('fs:changed', (event, data) => callback(data));
  },
  
  // Cleanup listener
  removeFileListener: () => 
    ipcRenderer.removeAllListeners('fs:changed'),
});

// TypeScript: declarar tipos globales
declare global {
  interface Window {
    electronAPI: {
      getAppVersion: () => string;
      readFile: (path: string) => Promise<string>;
      saveFile: (content: string, path: string) => Promise<void>;
      onFileSystemChange: (callback: (data: any) => void) => void;
      removeFileListener: () => void;
    };
  }
}

export {};
```

## 3. Comunicación IPC: Main ↔ Renderer

### Main Process (src/main.ts)

```javascript
import { app, BrowserWindow, ipcMain, dialog } from 'electron';
import path from 'path';
import fs from 'fs/promises';

let mainWindow;

const createWindow = () => {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      nodeIntegration: false,        // SEGURIDAD: disabled
      contextIsolation: true,        // SEGURIDAD: enabled
      preload: path.join(__dirname, 'preload.js'),
      sandbox: true,                 // SEGURIDAD: sandbox renderer
      enableRemoteModule: false,
    },
  });

  if (VITE_DEV_SERVER_URL) {
    mainWindow.loadURL(VITE_DEV_SERVER_URL);
    mainWindow.webContents.openDevTools();
  } else {
    mainWindow.loadFile(path.join(__dirname, '../renderer/index.html'));
  }
};

// Listeners IPC con validación
ipcMain.handle('file:read', async (event, filePath) => {
  try {
    // Validar ruta para evitar directory traversal
    const resolvedPath = path.resolve(filePath);
    const allowedDir = path.join(app.getPath('userData'), 'documents');
    
    if (!resolvedPath.startsWith(allowedDir)) {
      throw new Error('Acceso denegado: ruta fuera de documentos');
    }

    return await fs.readFile(resolvedPath, 'utf-8');
  } catch (error) {
    throw new Error(`Error leyendo archivo: ${error.message}`);
  }
});

ipcMain.handle('file:save', async (event, { content, filePath }) => {
  try {
    const resolvedPath = path.resolve(filePath);
    const allowedDir = path.join(app.getPath('userData'), 'documents');
    
    if (!resolvedPath.startsWith(allowedDir)) {
      throw new Error('Acceso denegado: ruta fuera de documentos');
    }

    await fs.writeFile(resolvedPath, content, 'utf-8');
  } catch (error) {
    throw new Error(`Error guardando archivo: ${error.message}`);
  }
});

// Dialog seguro para seleccionar archivos
ipcMain.handle('file:open-dialog', async () => {
  const { filePaths } = await dialog.showOpenDialog(mainWindow, {
    properties: ['openFile', 'multiSelections'],
    filters: [{ name: 'Documentos', extensions: ['txt', 'md', 'json'] }],
  });
  return filePaths;
});

app.on('ready', createWindow);
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});
```

### Renderer Process (React + Vite)

```javascript
// src/renderer/components/FileManager.tsx
import React, { useEffect, useState } from 'react';

export const FileManager = () => {
  const [content, setContent] = useState('');

  const openAndReadFile = async () => {
    try {
      const filePaths = await window.electronAPI.readFile('user-file.txt');
      setContent(filePaths);
    } catch (error) {
      console.error('Error:', error);
    }
  };

  const saveCurrentContent = async () => {
    try {
      await window.electronAPI.saveFile(content, 'user-file.txt');
      alert('Archivo guardado');
    } catch (error) {
      console.error('Error:', error);
    }
  };

  useEffect(() => {
    window.electronAPI.onFileSystemChange((data) => {
      console.log('Sistema de archivos cambió:', data);
    });

    return () => window.electronAPI.removeFileListener();
  }, []);

  return (
    <div>
      <textarea value={content} onChange={(e) => setContent(e.target.value)} />
      <button onClick={openAndReadFile}>Abrir</button>
      <button onClick={saveCurrentContent}>Guardar</button>
    </div>
  );
};
```

## 4. Build Tools Modernos: esbuild y Vite

### Vite como herramienta principal

```javascript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  build: {
    outDir: 'dist',
    sourcemap: false, // Cambiar a true en desarrollo
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
        },
      },
    },
  },
  server: {
    port: 5173,
    strictPort: true,
  },
});
```

### esbuild para Main Process y Preload

```javascript
// build.ts (script de construcción)
import * as esbuild from 'esbuild';
import path from 'path';

const buildOptions = {
  platform: 'node',
  target: 'node18',
  external: ['electron'],
};

// Build main process
await esbuild.build({
  ...buildOptions,
  entryPoints: ['src/main.ts'],
  outfile: 'dist/main.js',
  bundle: true,
  minify: true,
});

// Build preload script
await esbuild.build({
  ...buildOptions,
  entryPoints: ['src/preload.ts'],
  outfile: 'dist/preload.js',
  bundle: true,
});

console.log('Build completado');
```

## 5. Electron Forge: Configuración y Empaquetado

### electron-forge.config.ts

```javascript
import type { ForgeConfig } from '@electron-forge/shared-types';
import { MakerSquirrel } from '@electron-forge/maker-squirrel';
import { MakerZIP } from '@electron-forge/maker-zip';
import { MakerDMG } from '@electron-forge/maker-dmg';
import { MakerWix } from '@electron-forge/maker-wix';
import { WebpackPlugin } from '@electron-forge/plugin-webpack';
import path from 'path';

const config: ForgeConfig = {
  packagerConfig: {
    asar: true,
    icon: path.resolve(__dirname, 'assets/icon'),
    osxSign: {
      identity: 'Developer ID Application: Company Name',
      'hardened-runtime': true,
      entitlements: 'entitlements.plist',
      'entitlements-inherit': 'entitlements.plist',
      'signature-flags': 'library',
    },
    osxNotarize: {
      tool: 'notarytool',
      appleId: process.env.APPLE_ID,
      appleIdPassword: process.env.APPLE_ID_PASSWORD,
      teamId: process.env.APPLE_TEAM_ID,
    },
  },
  
  rebuildConfig: {},
  
  makers: [
    // Windows: NSIS installer
    new MakerSquirrel({
      certificateFile: process.env.WINDOWS_CERTIFICATE_FILE,
      certificatePassword: process.env.WINDOWS_CERTIFICATE_PASSWORD,
      signingUrl: 'http://signtool.example.com',
      sign: './customSign.js',
    }),
    
    // macOS: DMG
    new MakerDMG({
      format: 'ULFO',
      icon: path.resolve(__dirname, 'assets/icon.icns'),
      background: path.resolve(__dirname, 'assets/dmg-background.png'),
      contents: [
        {
          x: 130,
          y: 220,
          type: 'file',
          path: '/path/to/built/app',
        },
        {
          x: 410,
          y: 220,
          type: 'link',
          path: '/Applications',
        },
      ],
    }),
    
    // Linux: AppImage
    new MakerZIP({}),
  ],

  publishers: [
    {
      name: '@electron-forge/publisher-github',
      config: {
        repository: {
          owner: 'your-org',
          name: 'your-app',
        },
        draft: true,
        prerelease: false,
      },
    },
  ],

  plugins: [
    new WebpackPlugin({
      mainConfig: './webpack.main.config.js',
      renderer: {
        config: './webpack.renderer.config.js',
        entryPoints: [
          {
            html: './src/renderer/index.html',
            js: './src/renderer/index.tsx',
            name: 'main_window',
          },
        ],
      },
    }),
  ],
};

export default config;
```

## 6. pnpm Workspaces: Estructura Monorepo

### pnpm-workspace.yaml

```yaml
packages:
  - 'packages/shared'
  - 'packages/core'
  - 'packages/preload'
  - 'packages/renderer'
  - 'packages/main'
```

### Orden de construcción: shared → core → preload → renderer → main

```javascript
// package.json raíz
{
  "name": "electron-monorepo",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "build": "pnpm -r --filter './packages/**' run build",
    "dev": "pnpm --filter main dev",
    "package": "electron-forge make",
  },
  "devDependencies": {
    "electron": "^latest",
    "electron-forge": "^latest",
  }
}
```

### packages/shared/package.json (Utilidades compartidas)

```json
{
  "name": "@monorepo/shared",
  "version": "1.0.0",
  "main": "dist/index.js",
  "scripts": {
    "build": "esbuild src/index.ts --outfile=dist/index.js --bundle"
  }
}
```

### packages/core/package.json (Lógica de negocio)

```json
{
  "name": "@monorepo/core",
  "version": "1.0.0",
  "main": "dist/index.js",
  "dependencies": {
    "@monorepo/shared": "workspace:*"
  },
  "scripts": {
    "build": "esbuild src/index.ts --outfile=dist/index.js --bundle"
  }
}
```

### packages/main/package.json (Main process)

```json
{
  "name": "@monorepo/main",
  "version": "1.0.0",
  "main": "dist/main.js",
  "dependencies": {
    "@monorepo/core": "workspace:*",
    "electron": "^latest"
  },
  "scripts": {
    "build": "esbuild src/main.ts --outfile=dist/main.js --bundle --external:electron",
    "dev": "electron dist/main.js"
  }
}
```

### packages/renderer/package.json (UI con React)

```json
{
  "name": "@monorepo/renderer",
  "version": "1.0.0",
  "dependencies": {
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "@monorepo/shared": "workspace:*"
  },
  "devDependencies": {
    "vite": "^latest",
    "@vitejs/plugin-react": "^latest"
  },
  "scripts": {
    "build": "vite build",
    "dev": "vite"
  }
}
```

## 7. Auto-actualizaciones con electron-updater

```javascript
// src/main.ts
import { autoUpdater } from 'electron-updater';

const setupAutoUpdater = () => {
  autoUpdater.checkForUpdatesAndNotify();

  autoUpdater.on('update-available', () => {
    mainWindow.webContents.send('update:available');
  });

  autoUpdater.on('update-downloaded', () => {
    mainWindow.webContents.send('update:downloaded');
  });

  autoUpdater.on('error', (error) => {
    console.error('Error en actualización:', error);
  });
};

ipcMain.handle('app:install-update', () => {
  autoUpdater.quitAndInstall();
});

app.on('ready', () => {
  createWindow();
  setupAutoUpdater();
});
```

### Renderer: UI para actualizaciones

```javascript
// src/renderer/components/UpdateDialog.tsx
import { useState, useEffect } from 'react';

export const UpdateDialog = () => {
  const [updateAvailable, setUpdateAvailable] = useState(false);
  const [updateDownloaded, setUpdateDownloaded] = useState(false);

  useEffect(() => {
    window.ipcRenderer.on('update:available', () => {
      setUpdateAvailable(true);
    });

    window.ipcRenderer.on('update:downloaded', () => {
      setUpdateDownloaded(true);
    });
  }, []);

  return (
    <>
      {updateAvailable && <p>Nueva versión disponible</p>}
      {updateDownloaded && (
        <button onClick={() => window.ipcRenderer.invoke('app:install-update')}>
          Instalar y reiniciar
        </button>
      )}
    </>
  );
};
```

## 8. Seguridad en Profundidad

### Headers de Seguridad (CSP)

```html
<!-- renderer/index.html -->
<!DOCTYPE html>
<html>
  <head>
    <meta 
      http-equiv="Content-Security-Policy" 
      content="
        default-src 'self'; 
        script-src 'self' 'unsafe-inline'; 
        style-src 'self' 'unsafe-inline'; 
        img-src 'self' data:; 
        connect-src 'self' https://api.example.com;
      " 
    />
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

### Checklist de Seguridad

1. **nodeIntegration**: false (nunca permitir)
2. **contextIsolation**: true (siempre)
3. **sandbox**: true (renderer process)
4. **preload**: especificar archivo preload
5. **enableRemoteModule**: false (deprecated, evitar)
6. **CSP headers**: implementar Content-Security-Policy
7. **Validación de rutas**: usar path.resolve() con allowlist
8. **No eval()**: nunca usar eval o Function()

## 9. Acceso al Sistema de Archivos

### Dialog API Segura

```javascript
// Main process
ipcMain.handle('file:save-dialog', async (event, defaultName) => {
  const { filePath } = await dialog.showSaveDialog(mainWindow, {
    defaultPath: defaultName,
    filters: [
      { name: 'Documentos', extensions: ['txt', 'md'] },
      { name: 'Todos', extensions: ['*'] },
    ],
  });
  return filePath;
});

// Renderer
const filePath = await window.electronAPI.saveFileDialog('mi-documento.txt');
```

### Safe Path Handling

```javascript
import path from 'path';

const validatePath = (filePath) => {
  const baseDir = app.getPath('userData');
  const resolved = path.resolve(filePath);
  
  // Prevenir directory traversal
  if (!resolved.startsWith(baseDir)) {
    throw new Error('Ruta fuera de permitido');
  }
  
  return resolved;
};
```

## 10. Tray Apps y Notificaciones del Sistema

```javascript
// Tray application
import { Tray, Menu, nativeImage } from 'electron';

let tray;

const createTray = () => {
  const icon = nativeImage.createFromPath('assets/icon.png').resize({ width: 16, height: 16 });
  tray = new Tray(icon);

  const contextMenu = Menu.buildFromTemplate([
    { label: 'Abrir', click: () => mainWindow.show() },
    { type: 'separator' },
    { label: 'Salir', click: () => app.quit() },
  ]);

  tray.setContextMenu(contextMenu);
  tray.setToolTip('Mi App Electron');
  tray.on('click', () => mainWindow.show());
};

// Notificaciones nativas
import { Notification } from 'electron';

const sendNotification = (title, body) => {
  new Notification({
    title,
    body,
    icon: 'assets/icon.png',
  }).show();
};

ipcMain.handle('notification:send', (event, { title, body }) => {
  sendNotification(title, body);
});
```

## 11. React + Vite en Renderer

### vite.config.ts optimizado

```javascript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  build: {
    outDir: 'dist',
    minify: 'terser',
    sourcemap: false,
    rollupOptions: {
      output: {
        manualChunks: (id) => {
          if (id.includes('node_modules')) return 'vendor';
        },
      },
    },
  },
});
```

## 12. Performance: Lazy Loading y Workers

### Code Splitting con React

```javascript
import { lazy, Suspense } from 'react';

const HeavyComponent = lazy(() => import('./HeavyComponent'));

export const App = () => (
  <Suspense fallback={<div>Cargando...</div>}>
    <HeavyComponent />
  </Suspense>
);
```

### Web Workers para CPU-intensive

```javascript
// src/workers/processor.ts
const ctx: Worker = self as any;

ctx.onmessage = (event) => {
  const data = event.data;
  const result = heavyComputation(data);
  ctx.postMessage(result);
};
```

```javascript
// En renderer
const worker = new Worker(new URL('./workers/processor.ts', import.meta.url), {
  type: 'module',
});

worker.postMessage(largeDataset);
worker.onmessage = (event) => {
  console.log('Resultado:', event.data);
};
```

## 13. Distribución Multiplataforma

### macOS: DMG y Notarización

Requerimientos:
- Developer ID Application certificate
- Apple ID y App-specific password
- Entitlements.plist para hardened runtime

```javascript
// electron-forge.config.ts (macOS)
osxNotarize: {
  tool: 'notarytool',
  appleId: process.env.APPLE_ID,
  appleIdPassword: process.env.APPLE_ID_PASSWORD,
  teamId: process.env.APPLE_TEAM_ID,
}
```

### Windows: NSIS Installer

```javascript
// electron-forge.config.ts (Windows)
new MakerSquirrel({
  certificateFile: process.env.WINDOWS_CERT,
  certificatePassword: process.env.WINDOWS_CERT_PW,
})
```

### Linux: AppImage

```bash
# Configuración automática con Electron Forge
# Los usuarios descargan .AppImage y lo hacen ejecutable
chmod +x app.AppImage
./app.AppImage
```

## 14. Casos de Uso Comunes

### Local-First Apps
- Aplicaciones que almacenan datos localmente
- Sincronización opcional con servidores
- Ejemplo: Notion, Obsidian

### Tray Utilities
- Apps que viven en system tray
- Acceso rápido sin ventana principal
- Ejemplo: Alfred, Clipboard managers

### Cross-platform Tooling
- DevTools, linters, builders
- Acceso a CLI desde GUI
- Ejemplo: VSCode, Figma

## 15. Conclusiones

**Best Practices Resumen:**
1. Usar Vite para renderer, esbuild para main/preload
2. pnpm workspaces para monorepos ordenados
3. contextBridge + IPC para seguridad
4. Electron Forge + electron-updater para distribución
5. CSP headers + validación de rutas
6. Code splitting y lazy loading para performance
7. Auto-updates para mantener usuarios actualizados

**Recursos:**
- Electron Docs: https://www.electronjs.org/docs
- Electron Security: https://www.electronjs.org/docs/tutorial/security
- Electron Forge: https://www.electronforge.io/
- electron-updater: https://github.com/electron-userland/electron-builder
