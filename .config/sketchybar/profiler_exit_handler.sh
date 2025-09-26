#!/bin/bash

# SketchyBar Profiler Exit Handler
# This script captures final profiling data when SketchyBar terminates

SKETCHYBAR_PID=$1
LOG_DIR="$HOME/.config/sketchybar/logs"
EXIT_LOG="$LOG_DIR/profiler_exit_$(date +%Y%m%d_%H%M%S).log"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Create exit log
cat > "$EXIT_LOG" << EOF
=== SketchyBar Profiler Exit Handler ===
Exit Time: $(date)
PID: $SKETCHYBAR_PID
Reason: Process termination detected

=== FINAL METRICS ===
EOF

# Try to get process information if available
if [[ -n "$SKETCHYBAR_PID" ]] && kill -0 "$SKETCHYBAR_PID" 2>/dev/null; then
    echo "Process still running, capturing final state..." >> "$EXIT_LOG"
    
    # Get process runtime
    if command -v ps >/dev/null; then
        ps -p "$SKETCHYBAR_PID" -o pid,etime,pcpu,pmem >> "$EXIT_LOG" 2>/dev/null || true
    fi
else
    echo "Process $SKETCHYBAR_PID has terminated" >> "$EXIT_LOG"
fi

# Add system resource usage
echo "" >> "$EXIT_LOG"
echo "=== SYSTEM STATE ===" >> "$EXIT_LOG"
date >> "$EXIT_LOG"
uptime >> "$EXIT_LOG"

# Try to find the most recent profiler log
LATEST_PROFILE_LOG=$(ls -t "$LOG_DIR"/profile_*.log 2>/dev/null | head -n1)
if [[ -n "$LATEST_PROFILE_LOG" ]]; then
    echo "" >> "$EXIT_LOG"
    echo "=== LATEST PROFILE DATA ===" >> "$EXIT_LOG"
    echo "Source: $LATEST_PROFILE_LOG" >> "$EXIT_LOG"
    tail -n 50 "$LATEST_PROFILE_LOG" >> "$EXIT_LOG" 2>/dev/null || true
fi

# Log completion
echo "" >> "$EXIT_LOG"
echo "Exit handler completed at $(date)" >> "$EXIT_LOG"

# If debug mode, also output to console
if [[ "$SKETCHYBAR_DEBUG" == "1" ]]; then
    echo "🔚 SketchyBar profiler exit handler executed"
    echo "📊 Exit log saved to: $EXIT_LOG"
fi

# Clean up old logs (keep last 10)
find "$LOG_DIR" -name "profiler_exit_*.log" -type f | sort -r | tail -n +11 | xargs rm -f 2>/dev/null || true