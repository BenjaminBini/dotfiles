#!/bin/bash

# Formal test to prove profile_event is called multiple times from different locations
echo "🔬 Formal Test: Multiple profile_event Calls"
echo "=============================================="

# Enable debug output
export SKETCHYBAR_DEBUG=1

echo "🎯 HYPOTHESIS: profile_event() is being called multiple times from different code locations"
echo "🔍 WHAT TO LOOK FOR:"
echo "   📍 profile_event called from: [FILE:LINE] - Multiple different locations"
echo "   🟢 SUCCESS handler called - Should see multiple instances with different event IDs"
echo ""

# Start SketchyBar with debug output
echo "🚀 Starting SketchyBar with enhanced debugging..."
SKETCHYBAR_DEBUG=1 sketchybar &
SKETCHYBAR_PID=$!
sleep 3

echo ""
echo "🔄 Triggering focus change events to capture evidence..."

# Trigger focus changes
for i in {1..3}; do
    echo "--- Focus Change $i ---"
    aerospace focus right
    sleep 1
done

echo ""
echo "⏹️  Stopping SketchyBar..."
kill $SKETCHYBAR_PID
wait $SKETCHYBAR_PID 2>/dev/null

echo ""
echo "✅ Test completed!"
echo ""
echo "🔍 EVIDENCE TO ANALYZE:"
echo "----------------------"
echo "If multiple calls hypothesis is CORRECT, you should see:"
echo "  📍 profile_event called from: spaces.lua:XXX (first call)"  
echo "  📍 profile_event called from: spaces.lua:YYY (second call - different line!)"
echo "  🟢 SUCCESS handler called for aerospace_focus_change [EVENT_X_Y] (first)"
echo "  🟢 SUCCESS handler called for aerospace_focus_change [EVENT_A_B] (second - different ID!)"
echo ""
echo "If multiple calls hypothesis is WRONG, you should see:"
echo "  📍 profile_event called from: spaces.lua:XXX (only one location)"
echo "  🟢 SUCCESS handler called for aerospace_focus_change [EVENT_X_Y] (only one per event)"
echo ""
echo "The presence of DIFFERENT FILE:LINE locations proves multiple calls!"