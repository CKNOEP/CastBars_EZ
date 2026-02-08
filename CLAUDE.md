# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**CastBars_EZ** is a World of Warcraft addon that provides customizable casting bars with easy-to-use positioning and configuration. The addon is compatible with multiple WoW versions (Vanilla, TBC Classic, WOTLK, Cataclysm).

### Key Features
- Movable and resizable casting bars for player, target, pet, and focus frames
- Color customization for casting bars and channeling bars
- Minimap button for quick access to settings
- Layout mode to reposition and resize cast bars without unlocking them in normal gameplay
- Saved per-character database using AceDB

## Architecture

The addon follows the **Ace3 framework** architecture with these main components:

### Core Files

1. **CastBars_EZ.lua** (~1,480 lines) - Main entry point for Retail/TBC versions
   - Initializes the addon using AceAddon
   - Defines configuration options via AceConfig/AceGUI
   - Manages casting bar creation and updates
   - Handles color management and UI state

2. **CastBars_EZ_Vanilla.lua** (~1,473 lines) - Version-specific implementation for Vanilla/Cataclysm
   - Parallel implementation adapted for different WoW API versions
   - Same overall structure and function names as CastBars_EZ.lua

3. **CastBars_EZ.xml** - UI frame definitions
   - Defines the virtual frame template `ezCastBarTemplate` used to create individual cast bars
   - Includes statusbar, text display, timer, and resize button
   - Handles frame layout, anchoring, and visual elements (spark, flash effects)

4. **embeds.xml** - Ace library dependencies
   - Loads all required Ace3 libraries (AceAddon, AceDB, AceConfig, AceGUI, etc.)
   - Loads custom widget: AceGUIWidget-NumberEditBox.lua

### Version Files

- **CastBars_EZ.toc** - TOC for Retail (Interface: 40400)
- **CastBars_EZ-Vanilla.toc** - TOC for Vanilla (Interface: 11507)
- **CastBars_EZ-Classic.toc** - TOC for Classic TBC
- **CastBars_EZ-WOTLK.toc** - TOC for WOTLK
- **CastBars_EZ-Cata.toc** - TOC for Cataclysm

Each `.toc` file loads `embeds.xml`, `CastBars_EZ.xml`, and either `CastBars_EZ.lua` (Retail) or `CastBars_EZ_Vanilla.lua` (other versions).

## Key Code Structure

### Configuration & Options
- `EZCB_getOptions()` - Defines the AceConfig options table for slash commands and UI
- Options include visibility toggles, color pickers, minimap button control, and layout mode

### Addon Lifecycle
- `addon:OnInitialize()` - Sets up saved variables, creates initial cast bars, registers events and minimap button

### Cast Bar Management
- Individual frame names: `playerezCastBar`, `targetezCastBar`, `petezCastBar`, `focusezCastBar`
- Created from the `ezCastBarTemplate` and stored in `_G` for WoW access
- Each castbar has `.bar` (statusbar), `.bar.text`, `.bar.timer` for display

### Channeling Ticks
- `setBarTicks()` - Displays visual ticks on the casting bar for channeled spells
- `getChannelingTicksRate()` - Calculates tick duration for known spells
- `cleanTicks()` - Removes tick textures when casting ends

## Development Notes

### Database Structure
- Saved variables: `CastBars_EZDB`
- Stored per character in `addon.db.profile`
- Contains: visibility flags, colors (RGB+Alpha), positions, sizes for each cast bar unit

### Event Handling
- Uses AceEvent for unit casting events (UNIT_SPELLCAST_START, UNIT_SPELLCAST_STOP, etc.)
- Bucket events for performance optimization

### UI Customization
- Colors use RGBA table format: `{r, g, b, a}` (0-1 scale)
- Default colors: `{1, .7, 0, 1}` (orange)
- Non-interruptible cast color: `{.9, 0, 0, 1}` (red)

### Frame Locking
- `castbar.locked` flag controls whether bars can be moved/resized
- Toggle layout mode via slash command to enable repositioning

## Common Development Tasks

### Testing Changes
- Test on at least two WoW versions (Retail and one Classic version) due to separate Lua files
- Changes to `CastBars_EZ.lua` don't affect Vanilla/Classic - must update `CastBars_EZ_Vanilla.lua` separately
- Use `/castbar layoutmode` command in-game to verify positioning and sizing work

### Adding New Options
1. Add configuration entry to `EZCB_getOptions()` options table
2. Store/retrieve from `addon.db.profile`
3. Implement getter/setter functions in the config table

### Handling New Game Versions
- Update the appropriate `.toc` file (Interface version)
- Test with both `CastBars_EZ.lua` and `CastBars_EZ_Vanilla.lua` if API changes affect both

## Dependencies
- **Ace3 Framework** - All standard Ace3 libraries for addon structure, configuration, database, and UI
- **LibDataBroker** - Minimap button integration
- **LibDBIcon-1.0** - Minimap icon display
