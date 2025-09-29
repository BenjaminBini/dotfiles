export SWIFTLY_HOME_DIR="/Users/benjaminbini/.config/swiftly"
export SWIFTLY_BIN_DIR="/Users/benjaminbini/.config/swiftly/bin"
if [[ ":$PATH:" != *":$SWIFTLY_BIN_DIR:"* ]]; then
    export PATH="$SWIFTLY_BIN_DIR:$PATH"
fi
