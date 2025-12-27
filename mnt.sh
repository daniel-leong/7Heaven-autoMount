#!/bin/bash

# ==============================================================================
# Script Name: mnt.sh
# Description: Dynamically lists rclone remotes and mounts them to standard
#              locations with optimized settings.
# ==============================================================================

# ------------------------------------------------------------------------------
# Configuration & Paths
# ------------------------------------------------------------------------------
# Detect OS for standard paths (Fallback to Linux defaults if not macOS)
if [[ "$(uname)" == "Darwin" ]]; then
    MOUNT_BASE="/Volumes"
    CACHE_BASE="$HOME/Library/Caches/rclone"
    LOG_BASE="$HOME/Library/Logs/rclone"
else
    MOUNT_BASE="$HOME/mnt"
    CACHE_BASE="$HOME/.cache/rclone"
    LOG_BASE="$HOME/.log/rclone"
fi

# Ensure base directories exist
mkdir -p "$CACHE_BASE"
mkdir -p "$LOG_BASE"

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------

check_rclone() {
    if ! command -v rclone &> /dev/null; then
        echo "Error: rclone is not installed or not in your PATH."
        exit 1
    fi
}

get_remotes() {
    # Get list of remotes (stripped of trailing colon)
    rclone listremotes | sed 's/://g'
}

display_menu() {
    echo "====================================================="
    echo "   Rclone Mount Manager"
    echo "====================================================="
    echo "Fetching available cloud services..."
    echo " "
    
    # Read remotes into an array
    local remotes_list=($(get_remotes))
    
    if [ ${#remotes_list[@]} -eq 0 ]; then
        echo "No remotes found in rclone config."
        exit 1
    fi

    echo "Available Cloud Services:"
    for remote in "${remotes_list[@]}"; do
        echo "  - $remote"
    done
    echo " "
    echo "  Q) Quit"
    echo " "
}

mount_remote() {
    local remote_name="$1"
    
    # Standardize mount point and paths
    local mount_point="$MOUNT_BASE/$remote_name"
    local cache_dir="$CACHE_BASE/$remote_name"
    local log_file="$LOG_BASE/$remote_name.log"

    echo "-----------------------------------------------------"
    echo "Preparing to mount '$remote_name'..."
    echo "  Mount Point : $mount_point"
    echo "  Cache Dir   : $cache_dir"
    echo "  Log File    : $log_file"
    echo "-----------------------------------------------------"

    # 1. Create Mount Point
    if [ ! -d "$mount_point" ]; then
        echo "Creating mount point: $mount_point"
        # Using sudo for /Volumes if necessary, though user might own it or we need permissions
        # On modern macOS, /Volumes is writable by root, we might need sudo mkdir if script run as user
        if [ ! -w "$(dirname "$mount_point")" ]; then
             echo "Requesting sudo permission to create mount point in $MOUNT_BASE..."
             sudo mkdir -p "$mount_point"
             sudo chown "$USER" "$mount_point"
        else
             mkdir -p "$mount_point"
        fi
    fi

    # 2. Check if already mounted
    if mount | grep -q "on $mount_point"; then
        echo "Warning: $mount_point is already mounted."
        read -p "Do you want to unmount it first? (y/n): " unmount_choice
        if [[ "$unmount_choice" =~ ^[Yy]$ ]]; then
            umount "$mount_point" || sudo umount "$mount_point"
            echo "Unmounted."
        else
            return
        fi
    fi

    # 3. Mount Command
    # Optimized parameters for stability and performance
    echo "Executing rclone mount..."
    
    # Note: --allow-other requires 'user_allow_other' in /etc/fuse.conf on macOS/Linux
    rclone mount "$remote_name": "$mount_point" \
        --daemon \
        --volname "$remote_name" \
        --allow-other \
        --vfs-cache-mode full \
        --vfs-cache-max-size 20G \
        --vfs-cache-max-age 48h \
        --vfs-read-ahead 128M \
        --vfs-write-back 10s \
        --buffer-size 64M \
        --dir-cache-time 24h \
        --poll-interval 1m \
        --attr-timeout 1m \
        --cache-dir "$cache_dir" \
        --log-file "$log_file" \
        --log-level INFO \
        --user-agent "rclone_mount_script" \
        --no-modtime \
        --no-checksum

    if [ $? -eq 0 ]; then
        echo "✅ Success! '$remote_name' is mounted at $mount_point"
        
        # Optional: Attempt to reveal in Finder (macOS only)
        if [[ "$(uname)" == "Darwin" ]]; then
            open "$mount_point" 2>/dev/null
        fi
    else
        echo "❌ Failed to mount '$remote_name'. Check log at $log_file"
    fi
}

# ------------------------------------------------------------------------------
# Main Execution
# ------------------------------------------------------------------------------

check_rclone

# Check if an argument is provided (e.g., ./mnt.sh OODL or ./mnt.sh -OODL)
if [ -n "$1" ]; then
    # Sanitize input: remove potential leading dashes so both "OODL" and "-OODL" work
    target_remote=$(echo "$1" | sed 's/^-*//')

    # Validate against available remotes
    if get_remotes | grep -Fqx "$target_remote"; then
        mount_remote "$target_remote"
        exit 0
    else
        echo "Error: Remote '$target_remote' is not configured in rclone."
        echo "Run the script without arguments to see available remotes."
        exit 1
    fi
fi

while true; do
    display_menu
    
    echo -n "Enter the 4-character code of the service to mount (or Q): "
    read -r choice

    # Trim whitespace and handle Quit
    choice=$(echo "$choice" | xargs)
    if [[ "$choice" == "q" || "$choice" == "Q" ]]; then
         echo "Goodbye!"
         exit 0
    fi

    # Verify if choice is in list
    available_remotes=$(get_remotes) 
    if echo "$available_remotes" | grep -Fqx "$choice"; then
        mount_remote "$choice"
        
        # Pause to let user read output
        echo " "
        read -p "Press Enter to continue..."
    else
        echo " "
        echo "⚠️  Invalid Selection: '$choice' does not match any existing remote."
        echo "Please verify the code from the list above."
        echo " "
        read -p "Press Enter to try again..."
    fi
done
