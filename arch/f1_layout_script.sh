#!/bin/bash

# Configuration - use regex patterns
# Format: "pattern"="workspace,monitor_index,x_pct,y_pct,w_pct,h_pct"
declare -A WINDOW_CONFIGS=(
    # Workspace 3 - 2x3 grid on monitor 0 (split into 3 columns and 2 rows)
    [".*F1 Live.*"]="3,0,0,0,34,50"
    [".*Data Channel.*"]="3,0,0,50,34,50"
    [".*Track Map.*"]="3,0,34,0,33,50"
    [".*Max Verstappen.*"]="3,0,34,50,33,50"
    [".*Lando Norris.*"]="3,0,67,0,33,50"
    [".*Oscar Piastri.*"]="3,0,67,50,33,50"
    
    # Workspace 4 - vertical split into thirds on monitor 1
    [".*Race Trace.*"]="4,1,0,0,100,33"
    [".*Radio Transcriptions.*"]="4,1,0,33,100,34"
    [".*Live Timing.*"]="4,1,0,67,100,33"
)

# Track which workspaces we've already set up
declare -A WORKSPACE_SETUP
# Track dummy window PIDs (not addresses) so we can kill them
declare -A DUMMY_PIDS
# Track window count per workspace for cleanup
declare -A WORKSPACE_WINDOW_COUNT

echo "[DEBUG] Script started at $(date)"
echo "[DEBUG] Configured patterns:"
for pattern in "${!WINDOW_CONFIGS[@]}"; do
    echo "  - $pattern -> ${WINDOW_CONFIGS[$pattern]}"
done

# Count expected windows per workspace
count_expected_windows() {
    local workspace=$1
    local count=0
    for pattern in "${!WINDOW_CONFIGS[@]}"; do
        local config="${WINDOW_CONFIGS[$pattern]}"
        IFS=',' read -r ws _ _ _ _ _ <<< "$config"
        if [ "$ws" = "$workspace" ]; then
            ((count++))
        fi
    done
    echo $count
}

# Get monitor info by index (returns: x y width height transform)
# transform: 0=normal, 1=90°, 2=180°, 3=270°
get_monitor_info() {
    local monitor_index=$1
    echo "[DEBUG] Getting monitor info for monitor index $monitor_index" >&2
    
    # Get all info including transform
    local result=$(hyprctl monitors -j | jq -r ".[$monitor_index] | \"\(.x) \(.y) \(.width) \(.height) \(.transform)\"")
    echo "[DEBUG] Monitor raw info: '$result'" >&2
    
    read mon_x mon_y mon_w mon_h transform <<< "$result"
    
    # If monitor is rotated 90° or 270°, swap width and height
    if [ "$transform" = "1" ] || [ "$transform" = "3" ]; then
        echo "[DEBUG] Monitor is rotated (transform=$transform), swapping width/height" >&2
        echo "$mon_x $mon_y $mon_h $mon_w"
    else
        echo "$mon_x $mon_y $mon_w $mon_h"
    fi
}

# Get monitor name by index
get_monitor_name() {
    local monitor_index=$1
    echo "[DEBUG] Getting monitor name for index $monitor_index" >&2
    local result=$(hyprctl monitors -j | jq -r ".[$monitor_index].name")
    echo "[DEBUG] Monitor name: '$result'" >&2
    echo "$result"
}

# Ensure workspace exists on the correct monitor using a dummy window
ensure_workspace_on_monitor() {
    local workspace=$1
    local monitor_name=$2
    
    # Check if we've already set up this workspace
    if [ "${WORKSPACE_SETUP[$workspace]}" = "$monitor_name" ]; then
        echo "[DEBUG] Workspace $workspace already set up on $monitor_name"
        return 0
    fi
    
    echo "[DEBUG] Creating workspace $workspace on monitor $monitor_name using dummy window"
    
    # Launch ghostty - just run an infinite loop that does nothing
    # This won't trigger a close confirmation
    ghostty -e sh -c "while true; do sleep 1000; done" &
    local ghostty_pid=$!
    echo "[DEBUG] Launched dummy window with PID $ghostty_pid"
    
    # Store the PID for later cleanup
    DUMMY_PIDS[$workspace]=$ghostty_pid
    
    # Wait for the window to appear and get its address
    local attempts=0
    local dummy_address=""
    while [ $attempts -lt 20 ]; do
        sleep 0.1
        # Find the newest ghostty window (by PID proximity)
        dummy_address=$(hyprctl clients -j | jq -r ".[] | select(.pid == $ghostty_pid) | .address" | head -n1)
        if [ -n "$dummy_address" ]; then
            break
        fi
        ((attempts++))
        echo "[DEBUG] Waiting for dummy window... attempt $attempts/20"
    done
    
    if [ -z "$dummy_address" ]; then
        echo "[ERROR] Failed to find dummy window after $attempts attempts"
        echo "[DEBUG] Current ghostty windows:"
        hyprctl clients -j | jq -r '.[] | select(.class == "com.mitchellh.ghostty") | "  PID:\(.pid) Title:\(.title) - \(.address)"'
        kill -9 $ghostty_pid 2>/dev/null
        return 1
    fi
    
    # Add 0x prefix if needed
    if [[ ! $dummy_address =~ ^0x ]]; then
        dummy_address="0x$dummy_address"
    fi
    
    echo "[DEBUG] Dummy window address: $dummy_address"
    
    # Move dummy window to target workspace
    echo "[DEBUG] Moving dummy to workspace $workspace"
    hyprctl dispatch movetoworkspacesilent "$workspace,address:$dummy_address"
    sleep 0.2
    
    # Move the workspace to the correct monitor
    echo "[DEBUG] Moving workspace $workspace to monitor $monitor_name"
    hyprctl dispatch moveworkspacetomonitor "$workspace $monitor_name"
    sleep 0.2
    
    # Verify the workspace is on the correct monitor
    local actual_monitor=$(hyprctl workspaces -j | jq -r ".[] | select(.id == $workspace) | .monitor")
    echo "[DEBUG] Workspace $workspace is now on monitor: $actual_monitor (expected: $monitor_name)"
    
    # Mark this workspace as set up
    WORKSPACE_SETUP[$workspace]="$monitor_name"
    echo "[DEBUG] Workspace $workspace setup complete"
}

# Clean up dummy window for a workspace
cleanup_dummy_window() {
    local workspace=$1
    
    if [ -n "${DUMMY_PIDS[$workspace]}" ]; then
        echo "[DEBUG] Killing dummy process for workspace $workspace: PID ${DUMMY_PIDS[$workspace]}"
        kill -9 ${DUMMY_PIDS[$workspace]} 2>/dev/null
        unset DUMMY_PIDS[$workspace]
    fi
}

layout_window() {
    local address=$1
    local title=$2
    local config=$3
    
    # Add 0x prefix if not present
    if [[ ! $address =~ ^0x ]]; then
        address="0x$address"
    fi
    
    echo "[DEBUG] === layout_window called ==="
    echo "[DEBUG] Address: $address"
    echo "[DEBUG] Title: '$title'"
    echo "[DEBUG] Config: '$config'"
    
    IFS=',' read -r workspace monitor_index x_pct y_pct w_pct h_pct <<< "$config"
    
    echo "[DEBUG] Parsed: workspace=$workspace monitor=$monitor_index x=$x_pct% y=$y_pct% w=$w_pct% h=$h_pct%"
    
    # Ensure the workspace exists on the correct monitor BEFORE getting monitor info
    local monitor_name=$(get_monitor_name $monitor_index)
    ensure_workspace_on_monitor "$workspace" "$monitor_name"
    
    # NOW get monitor info - this ensures we get the right monitor's dimensions
    # The function will handle rotation and swap dimensions if needed
    read monitor_x monitor_y monitor_w monitor_h < <(get_monitor_info $monitor_index)
    
    if [ -z "$monitor_w" ] || [ -z "$monitor_h" ]; then
        echo "[ERROR] Could not get dimensions for monitor $monitor_index"
        return 1
    fi
    
    echo "[DEBUG] Monitor $monitor_index: $monitor_name at ${monitor_x},${monitor_y} effective size ${monitor_w}x${monitor_h} (rotation-adjusted)"
    
    # Calculate pixel values RELATIVE to monitor position
    local rel_x=$((monitor_w * x_pct / 100))
    local rel_y=$((monitor_h * y_pct / 100))
    local w=$((monitor_w * w_pct / 100))
    local h=$((monitor_h * h_pct / 100))
    
    # Add monitor offset for absolute position (floating windows use absolute coords)
    local abs_x=$((monitor_x + rel_x))
    local abs_y=$((monitor_y + rel_y))
    
    echo "[INFO] Laying out '$title' -> Monitor:$monitor_name WS:$workspace size:${w}x${h} at absolute:${abs_x},${abs_y} (rel:${rel_x},${rel_y})"
    
    # Use address-based commands to avoid race conditions
    
    echo "[DEBUG] Step 1: Move to workspace $workspace"
    hyprctl dispatch movetoworkspacesilent "$workspace,address:$address"
    local result=$?
    echo "[DEBUG] Move result: $result"
    sleep 0.1
    
    echo "[DEBUG] Step 2: Set floating"
    hyprctl dispatch setfloating "address:$address"
    result=$?
    echo "[DEBUG] Setfloating result: $result"
    sleep 0.1
    
    echo "[DEBUG] Step 3: Resize to ${w}x${h}"
    hyprctl dispatch resizewindowpixel "exact $w $h,address:$address"
    result=$?
    echo "[DEBUG] Resize result: $result"
    sleep 0.1
    
    echo "[DEBUG] Step 4: Move to absolute position ${abs_x},${abs_y}"
    hyprctl dispatch movewindowpixel "exact $abs_x $abs_y,address:$address"
    result=$?
    echo "[DEBUG] Move result: $result"
    
    # Increment window count for this workspace
    WORKSPACE_WINDOW_COUNT[$workspace]=$((${WORKSPACE_WINDOW_COUNT[$workspace]:-0} + 1))
    local expected=$(count_expected_windows $workspace)
    echo "[DEBUG] Workspace $workspace: ${WORKSPACE_WINDOW_COUNT[$workspace]}/$expected windows placed"
    
    # Clean up dummy window if all expected windows are placed
    if [ "${WORKSPACE_WINDOW_COUNT[$workspace]}" -ge "$expected" ]; then
        echo "[DEBUG] All $expected windows placed for workspace $workspace, cleaning up dummy in 1 second"
        (sleep 1; cleanup_dummy_window $workspace) &
    fi
    
    echo "[DEBUG] === layout_window complete ==="
}

# Listen to Hyprland events
handle_event() {
    echo "[DEBUG] Starting event handler loop"
    local line_count=0
    while IFS= read -r line; do
        ((line_count++))
        echo "[DEBUG] Event #$line_count: $line"
        
        # Match windowtitlev2 event: windowtitlev2>>ADDRESS,TITLE
        if [[ $line =~ ^windowtitlev2\>\>([^,]+),(.+)$ ]]; then
            local address="${BASH_REMATCH[1]}"
            local title="${BASH_REMATCH[2]}"
            
            echo "[DEBUG] Windowtitlev2 event detected!"
            echo "[DEBUG]   Address: $address"
            echo "[DEBUG]   Title: '$title'"
            
            # Check if this title matches any of our configured windows (using regex)
            local matched=false
            for pattern in "${!WINDOW_CONFIGS[@]}"; do
                echo "[DEBUG]   Testing pattern: $pattern"
                if [[ $title =~ $pattern ]]; then
                    echo "[INFO] ✓ MATCH! Title '$title' matched pattern '$pattern'"
                    layout_window "$address" "$title" "${WINDOW_CONFIGS[$pattern]}"
                    matched=true
                    break
                else
                    echo "[DEBUG]   ✗ No match"
                fi
            done
            
            if [ "$matched" = false ]; then
                echo "[DEBUG] No pattern matched for title: '$title'"
            fi
        fi
    done
}

# Main
if [ "$1" == "daemon" ]; then
    echo "[INFO] Starting F1 Multiviewer layout daemon..."
    echo "[DEBUG] XDG_RUNTIME_DIR: $XDG_RUNTIME_DIR"
    echo "[DEBUG] HYPRLAND_INSTANCE_SIGNATURE: $HYPRLAND_INSTANCE_SIGNATURE"
    
    # Show available monitors
    echo "[DEBUG] Available monitors:"
    hyprctl monitors -j | jq -r '.[] | "  [\(.id)] \(.name) at \(.x),\(.y) - \(.width)x\(.height) transform:\(.transform)"'
    
    # Show expected window counts
    echo "[DEBUG] Expected windows per workspace:"
    echo "  Workspace 3: $(count_expected_windows 3) windows"
    echo "  Workspace 4: $(count_expected_windows 4) windows"
    
    SOCKET_PATH="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
    echo "[DEBUG] Socket path: $SOCKET_PATH"
    
    if [ ! -S "$SOCKET_PATH" ]; then
        echo "[ERROR] Socket not found at $SOCKET_PATH"
        echo "[DEBUG] Available sockets:"
        ls -la "$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/" 2>/dev/null || echo "  Directory doesn't exist"
        exit 1
    fi
    
    echo "[INFO] Connected to Hyprland socket, listening for events..."
    socat -U - UNIX-CONNECT:$SOCKET_PATH | handle_event
else
    echo "Usage: $0 daemon"
    echo "Run this script in the background to automatically layout F1 Multiviewer windows"
fi
