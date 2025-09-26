# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a SketchyBar configuration written in Lua - a customizable macOS status bar positioned at the bottom of the
screen. The configuration includes widgets for system monitoring (CPU, battery, WiFi), workspace management (Aerospace
integration), media controls, and various system indicators.

## Key Development Commands

### Build System

```bash
make -C helpers/                    # Build all C helper programs
make -C helpers/helpers.event_providers/    # Build CPU and network monitoring binaries
sketchybar --reload                 # Reload configuration after changes
```

### Development Workflow

```bash
# After modifying Lua files
sketchybar --reload

# After modifying C helpers
make -C helpers/ && sketchybar --reload

# Debug configuration issues
sketchybar --query bar             # Check bar configuration
sketchybar --query default         # Check default item settings
```

## Architecture

### Module System

The configuration uses a modular Lua architecture with clear separation of concerns:

- **sketchybarrc**: Entry point that sets up Lua paths and requires main modules
- **init.lua**: Main configuration orchestrator that bundles setup into single message
- **bar.lua**: Bar positioning and styling configuration
- **default.lua**: Default styling applied to all items
- **items/**: Individual status bar components (aerospace, battery, etc.)
- **items/widgets/**: Reusable widget components with shared functionality
- **helpers/**: Shared configuration (colors, icons, settings) and C programs

### Configuration Flow

1. **sketchybarrc** → **helpers/init.lua** → **init.lua**
2. **init.lua** bundles: **bar.lua** → **default.lua** → **items/** → sends to SketchyBar
3. **sbar.event_loop()** handles callbacks and updates

### C Helper Programs

Performance-critical system monitoring uses compiled C programs:

- **helpers/helpers.event_providers/cpu_load/**: CPU usage monitoring
- **helpers/helpers.event_providers/network_load/**: Network traffic monitoring
- **helpers/menus/**: Menu interaction handling

All C programs compile to `bin/` directories and are automatically built by the Lua initialization.

### Shared Configuration

- **colors.lua**: Hex color palette with alpha blending utilities
- **icons.lua**: SF Symbols and Unicode icons for consistent theming
- **settings.lua**: Centralized styling (fonts, dimensions, colors) with workspace-specific theming

## Widget Architecture

Widgets follow a consistent pattern:

1. Import shared modules (colors, icons, settings)
2. Define item configuration with callbacks
3. Register event handlers for updates
4. Use helper programs for system data when needed

The bottom bar layout flows: Apple logo → Aerospace workspaces → Front app → (center) → Media controls → System
widgets (WiFi, Battery, CPU, Volume) → Calendar/Menu

## Testing Guidelines

- **Verification Process**:
    * Check your test results precisely with screenshots
    * Annotate screenshots to prove your conclusion
