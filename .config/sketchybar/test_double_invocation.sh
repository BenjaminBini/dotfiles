#!/bin/bash

# Test to investigate double invocation of profile_event
echo "🔍 INVESTIGATING: Double profile_event invocation"
echo "=============================================="

# Stop any existing SketchyBar
echo "🛑 Stopping existing SketchyBar..."
pkill -f sketchybar
sleep 2

# Clear previous debug log
if [ -f /tmp/sb_debug.log ]; then
    echo "🧹 Clearing previous debug log..."
    > /tmp/sb_debug.log
fi

echo "🔍 WHAT TO LOOK FOR:"
echo "   🔧 setup_observers() called - Should see once only"
echo "   🔧 Subscribing to aerospace_focus_change - Should see once only"
echo "   🎯 aerospace_focus_change callback triggered - How many times per window switch?"
echo "   📍 profile_event called from - How many times per callback?"
echo ""

# Start SketchyBar with debug output
echo "🚀 Starting SketchyBar with enhanced debugging..."
SKETCHYBAR_DEBUG=1 sketchybar > /tmp/sb_debug.log 2>&1 &
SKETCHYBAR_PID=$!
sleep 3

echo ""
echo "🔄 Triggering window focus changes..."

# Open test windows first
echo "📱 Opening test windows..."
open -a TextEdit
sleep 1
open -a Calculator  
sleep 2

# Trigger focus changes
for i in {1..3}; do
    echo "--- Focus Change $i ---"
    cmd+tab  # Switch between applications
    sleep 2
done

echo ""
echo "⏹️  Stopping SketchyBar..."
kill $SKETCHYBAR_PID
wait $SKETCHYBAR_PID 2>/dev/null

echo ""
echo "📊 ANALYZING DEBUG OUTPUT:"
echo "========================="

echo ""
echo "🔧 setup_observers() calls:"
grep "setup_observers() called" /tmp/sb_debug.log | wc -l | xargs echo "Count:"

echo ""
echo "🔧 Subscription setup calls:"
grep "Subscribing to aerospace_focus_change" /tmp/sb_debug.log | wc -l | xargs echo "Count:"

echo ""
echo "🎯 Callback trigger events:"
grep "aerospace_focus_change callback triggered" /tmp/sb_debug.log

echo ""
echo "📍 profile_event invocations:"
grep "profile_event called from" /tmp/sb_debug.log

echo ""
echo "✅ Analysis complete! Check counts above to identify double-invocation cause."