const vscode = require('vscode');
const fs = require('fs');
const os = require('os');
const path = require('path');
const { execFile, spawn } = require('child_process');

const HOME = os.homedir();
const STATE_FILE = path.join(HOME, '.local', 'state', 'ryoku-wallpaper');
const SYNC = path.join(HOME, '.local', 'bin', 'lily-vscodium-sync');
const RESTART = path.join(HOME, '.local', 'bin', 'lily-vscodium-restart');

let out;
let debounceTimer = null;
let lastSeenKey = '';
let lastNotifiedKey = '';
let isSyncing = false;
let pendingSync = false;
let isRestarting = false;

function readState() {
  try {
    return fs.readFileSync(STATE_FILE, 'utf8').trim();
  } catch {
    return '';
  }
}

function stateKey() {
  try {
    const stat = fs.statSync(STATE_FILE);
    return `${readState()}:${stat.size}:${stat.mtimeMs}`;
  } catch {
    return '';
  }
}

function runSyncProcess() {
  return new Promise((resolve) => {
    execFile(SYNC, [], { timeout: 90000, maxBuffer: 1024 * 1024 }, (err, stdout, stderr) => {
      if (err) {
        out.appendLine(`[sync error] ${err.message}`);
        if (stderr) out.appendLine(`[stderr] ${stderr}`);
        resolve(false);
      } else {
        out.appendLine(`[sync success] ${new Date().toLocaleTimeString()}`);
        resolve(true);
      }
    });
  });
}

async function syncAndNotify(force = false) {
  if (isSyncing) {
    pendingSync = true;
    return;
  }
  isSyncing = true;
  out.appendLine(`Syncing wallpaper rice (force=${force})...`);

  const statusBar = vscode.window.setStatusBarMessage('$(sync~spin) Lily: syncing wallpaper…');
  let ok = false;
  try {
    do {
      pendingSync = false;
      ok = await runSyncProcess();
    } while (ok && pendingSync);
  } finally {
    statusBar.dispose();
    isSyncing = false;
  }

  if (!ok) {
    vscode.window.showWarningMessage('Lily: could not sync the wallpaper palette. Check the Output panel for details.');
    return;
  }

  const currentKey = stateKey();
  if (!force && currentKey && currentKey === lastNotifiedKey) {
    out.appendLine('Skipping notification: key already notified.');
    return;
  }
  if (currentKey) {
    lastNotifiedKey = currentKey;
  }

  const choice = await vscode.window.showInformationMessage(
    'Lily palette and editor wallpaper updated. Restart VSCodium to apply them.',
    'Restart Now',
    'Later'
  );

  if (choice === 'Restart Now') {
    restartVscodium();
  }
}

function restartVscodium() {
  if (isRestarting) return;
  isRestarting = true;
  out.appendLine('Initiating restart helper...');

  try {
    const child = spawn(RESTART, [], { detached: true, stdio: 'ignore' });
    child.on('error', (err) => {
      isRestarting = false;
      vscode.window.showErrorMessage(`Lily: could not start restart helper: ${err.message}`);
      out.appendLine(`[restart helper error] ${err.message}`);
    });
    child.unref();

    setTimeout(() => {
      vscode.commands.executeCommand('workbench.action.quit');
    }, 400);
  } catch (err) {
    isRestarting = false;
    vscode.window.showErrorMessage(`Lily: restart failed: ${err.message}`);
    out.appendLine(`[restart exception] ${err.message}`);
  }
}

function activate(context) {
  out = vscode.window.createOutputChannel('Lily');
  context.subscriptions.push(out);
  out.appendLine('Lily rice watcher activated.');

  context.subscriptions.push(
    vscode.commands.registerCommand('lily.syncWallpaper', () => syncAndNotify(true)),
    vscode.commands.registerCommand('lily.restart', () => restartVscodium())
  );

  // Initialize keys with current file state so we don't trigger toast on initial startup
  lastSeenKey = stateKey();
  lastNotifiedKey = lastSeenKey;

  // Watch state file with fs.watchFile
  fs.watchFile(STATE_FILE, { interval: 1500 }, () => {
    const currentKey = stateKey();
    if (!currentKey || currentKey === lastSeenKey) return;
    lastSeenKey = currentKey;
    out.appendLine(`Detected wallpaper state change: ${currentKey}`);

    if (debounceTimer) clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => {
      syncAndNotify(false);
    }, 1200);
  });

  context.subscriptions.push({
    dispose: () => {
      if (debounceTimer) clearTimeout(debounceTimer);
      fs.unwatchFile(STATE_FILE);
    }
  });
}

function deactivate() {
  if (debounceTimer) clearTimeout(debounceTimer);
  fs.unwatchFile(STATE_FILE);
}

module.exports = {
  activate,
  deactivate
};
