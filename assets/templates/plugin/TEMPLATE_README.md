# Fluxo Plugin Template

This directory contains template files for creating Roblox Studio plugins with Fluxo.

## Template Variables

The following variables will be replaced when creating a new plugin:

- `$name` - The plugin name
- `$author` - The plugin author

## Linting Notes

The template files contain placeholder variables and will show linting errors in the editor. This is expected behavior. When you create a new plugin using `fluxo init --template plugin`, these templates will be processed and the variables will be replaced with actual values, resolving the linting issues.

## Files Included

- `src/.src.server.luau` - Main plugin entry point
- `src/ToolbarUI.lua` - UI handling module
- `plugin.meta.json` - Plugin metadata
- `fluxo.config.json` - Fluxo configuration
- `project.json` - Rojo project structure
- `selene.toml` - Selene linting configuration
