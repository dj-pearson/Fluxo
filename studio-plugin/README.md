# Fluxo Studio Plugin

This is the companion Studio plugin for Fluxo, providing a bridge between Roblox Studio and the Fluxo CLI tool.

## Features

- **Dashboard UI**: Modern interface for managing projects and viewing logs
- **Real-time Sync**: Bidirectional file synchronization with the CLI
- **Publishing**: Direct plugin publishing from Studio
- **Validation**: Project structure and code validation
- **Metadata Editor**: Visual editor for plugin metadata
- **HTTP Communication**: RESTful API communication with CLI
- **Logging**: Comprehensive logging system with multiple levels

## Architecture

### Core Modules

- `init.server.lua` - Main entry point and plugin initialization
- `ui/Dashboard.lua` - Main dashboard UI component
- `core/Server.lua` - HTTP server communication handler
- `core/Publish.lua` - Publishing functionality and UI
- `core/Sync.lua` - File synchronization and diff viewer
- `core/Validation.lua` - Project validation and reporting
- `core/MetadataEditor.lua` - Visual metadata editing interface
- `util/HttpClient.lua` - HTTP utility functions
- `util/Logger.lua` - Logging system with performance monitoring

### UI Components

The plugin provides several modal dialogs:
- **Dashboard**: Main control panel with project info, logs, and actions
- **Publish Modal**: Plugin publishing interface with metadata editing
- **Diff Viewer**: Side-by-side file comparison for sync operations
- **Validation Report**: Detailed validation results with issues, warnings, and suggestions
- **Metadata Editor**: Form-based metadata editing with validation

## Communication Protocol

The plugin communicates with the Fluxo CLI via HTTP on `localhost:8080` by default.

### API Endpoints

- `GET /health` - Health check
- `POST /sync` - Sync files from CLI to Studio
- `POST /publish` - Publish plugin from Studio
- `POST /validate` - Validate project structure

## Installation

1. Build the plugin using Rojo: `rojo build studio-plugin -o Fluxo.rbxmx`
2. Install the plugin in Studio via the Plugin Manager
3. The plugin will auto-detect a running CLI instance

## Development

The plugin uses strict typing (`--!strict`) and follows Roblox Luau best practices.

### Linting

Selene is configured with Roblox standards. Some linting warnings are expected for Studio plugins due to the specialized environment.

### Building

Use Rojo to build the plugin:
```bash
rojo build studio-plugin --output Fluxo.rbxmx
```

## Status

The plugin architecture is complete with all major components implemented:

✅ **Complete**:
- Basic plugin structure and entry point
- Dashboard UI framework
- HTTP communication utilities
- Logging system
- Publishing modal interface
- Sync handling with diff viewer
- Validation system with reporting
- Metadata editor with form validation

🚧 **In Progress**:
- Full integration testing
- Error handling improvements
- UI polish and animations
- Real CLI communication testing

📋 **TODO**:
- Performance optimizations
- Additional validation rules
- Advanced diff algorithms
- Plugin icon and branding
- Documentation and help system

## Dependencies

- Rojo for project management
- Selene for linting (optional)
- Roblox Studio Plugin API

## License

See LICENSE.md in the project root.
