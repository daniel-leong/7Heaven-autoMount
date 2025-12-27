# 7Heaven-autoMount
Set it once and forget it—this project delivers smart, reliable mounts with rclone. It mounts your drives exactly the way you want, every time. The goal is simple: reduce complexity, eliminate repetitive setup, and make cloud storage feel like a native part of your system—preset once, use forever, and enjoy effortless, dependable cloud mounting.



# Rclone Mount Manager 

This automated shell script that streamlines the `rclone` mount workflow. It provides an interactive menu to select which cloud remote to mount, or a fast CLI mode via arguments, and automatically applies optimized caching/performance settings.

## Features

- **Auto-detection**: Reads your `rclone.conf` on startup and lists all available remotes.
- **Two operation modes**
  - **Interactive menu**: Run without arguments to choose from a menu.
  - **Quick CLI**: Pass a remote name directly (e.g., `./mnt.sh OODL`) to mount immediately.
- **Standardized paths**
  - **Mount point**: Automatically creates the mount directory (macOS: `/Volumes/CODE`, Linux: `~/mnt/CODE`).
  - **Cache & logs**: Automatically manages cache and log files to keep your system tidy.
- **Performance defaults**: Includes advanced `rclone mount` options by default (VFS caching, buffer size, etc.) to improve streaming and file access performance.
- **Safety checks**: Verifies the target path isn’t already in use to prevent double-mounting.

## Prerequisites

Make sure the following are installed:

1. **Rclone**: https://rclone.org/install/  
   - You must run `rclone config` and create at least one remote.
2. **FUSE support**
   - **macOS**: Install **macFUSE**: https://osxfuse.github.io/  
     - Note: On Apple Silicon, you may need to allow kernel extensions in Recovery Mode.
   - **Linux**: Usually includes `fuse` by default; otherwise install it via your package manager.

## Usage

### 1) Make the script executable (first time only)
```
chmod +x mnt.sh
```
### 2) Interactive mode (menu)

Run the script:
```
./mnt.sh
```
You’ll see a menu like this—enter the 4-character code to mount:
```
=============================================
   Rclone Mount Manager
=============================================
Fetching available cloud services...

Available Cloud Services:
  - OODL
  - GDRV

  Q) Quit

Enter the 4-character code of the service to mount (or Q):
```
### 3) Quick CLI mode

If you already know the remote name (e.g., `OODL`), pass it as an argument to skip the menu:
```
# All three forms are supported
./mnt.sh OODL
./mnt.sh -OODL
./mnt.sh --OODL
```
This is useful for automation (e.g., scheduled tasks) or quick startup.

## Path Layout

Paths are chosen automatically based on your OS:

| Item | macOS (Darwin) | Linux / Other |
| --- | --- | --- |
| Mount point | `/Volumes/<Name>` | `~/mnt/<Name>` |
| Cache | `~/Library/Caches/rclone/<Name>` | `~/.cache/rclone/<Name>` |
| Logs | `~/Library/Logs/rclone/<Name>.log` | `~/.log/rclone/<Name>.log` |

## Key `rclone mount` Options

The script uses the following defaults for stability (you can edit them in the `mount_remote` function):

- `--vfs-cache-mode full`: Full VFS caching for reliable read/write behavior, even when the remote doesn’t support random writes.
- `--vfs-cache-max-size 20G`: Limits local cache to 20GB.
- `--buffer-size 64M`: Sets the in-memory buffer size.
- `--daemon`: Runs the mount in the background.

---

**Note**: To unmount, use `umount /path/to/mount`, or on macOS, eject the mounted drive (e.g., drag it to the Trash).


# Rclone Mount Manager 

這是一個自動化的 Shell Script，用於簡化 `rclone` 的掛載流程。它提供了一個互動式選單來選擇要掛載的雲端硬碟，或是透過指令參數快速掛載，並自動套用優化的快取與效能參數。

## 功能特點

*   **自動偵測**: 啟動時自動讀取 `rclone.conf` 設定，列出所有可用的 Remote。
*   **雙模式操作**:
    *   **互動選單**: 若不帶參數執行，會顯示選單供使用者選擇。
    *   **快速指令**: 支援直接帶入 Remote 名稱 (例如 `./mnt.sh OODL`) 快速掛載。
*   **標準化路徑**:
    *   **Mount Point**: 自動建立掛載點 (macOS: `/Volumes/CODE`, Linux: `~/mnt/CODE`)。
    *   **Cache & Logs**: 自動管理快取與日誌檔案，保持系統整潔。
*   **效能優化**: 預設包含許多進階 `rclone mount` 參數 (VFS Cahcing, Buffer size 等)，提升串流與檔案存取效能。
*   **安全檢查**: 掛載前檢查路徑是否已佔用，避免重複掛載。

## 前置需求

請確保您的系統已安裝以下軟體：

1.  **Rclone**: [安裝指南](https://rclone.org/install/)
    *   需完成 `rclone config` 設定至少一個 Remote。
2.  **FUSE 支援**:
    *   **macOS**: 需安裝 [macFUSE](https://osxfuse.github.io/) (注意：Apple Silicon Mac 需在 Recovery Mode 允許核心擴充功能)。
    *   **Linux**: 通常內建 `fuse`，若無請透過套件管理員安裝。

## 使用方式

### 1. 給予執行權限 (首次使用)

```bash
chmod +x mnt.sh
```

### 2. 互動模式 (選單)

直接執行腳本：

```bash
./mnt.sh
```

您將看到如下選單，輸入對應的代碼即可：

```text
=====================================================
   Rclone Mount Manager
=====================================================
Fetching available cloud services...

Available Cloud Services:
  - OODL
  - GDRV
  
  Q) Quit

Enter the 4-character code of the service to mount (or Q): 
```

### 3. 快速指令模式 (CLI)

如果您已知 Remote 的名稱 (例如 `OODL`)，可以直接透過參數執行，跳過選單：

```bash
# 以下三種方式皆可
./mnt.sh OODL
./mnt.sh -OODL
./mnt.sh --OODL
```

適合用於自動化排程或快速啟動。

## 路徑設定

腳本會根據作業系統自動決定路徑：

| 項目 | macOS (Darwin) | Linux / Other |
| :--- | :--- | :--- |
| **掛載點** | `/Volumes/<Name>` | `~/mnt/<Name>` |
| **快取 (Cache)** | `~/Library/Caches/rclone/<Name>` | `~/.cache/rclone/<Name>` |
| **日誌 (Logs)** | `~/Library/Logs/rclone/<Name>.log` | `~/.log/rclone/<Name>.log` |

## 參數說明

本腳本預設使用以下關鍵參數以確保穩定性 (您可於腳本內的 `mount_remote` 函式修改)：

*   `--vfs-cache-mode full`: 完整快取模式，支援讀寫，即使雲端不支援隨機寫入也能運作。
*   `--vfs-cache-max-size 20G`: 本地快取上限 20GB。
*   `--buffer-size 64M`: 記憶體緩衝區大小。
*   `--daemon`: 背景執行。

---
**注意**: 如需卸載，可使用 `umount /path/to/mount` 或在 macOS 上直接將磁碟圖示拖入垃圾桶。

--vfs-cache-max-size 20G: Limits local cache to 20GB.
--buffer-size 64M: Sets the in-memory buffer size.
--daemon: Runs the mount in the background.


