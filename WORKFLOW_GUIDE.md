# Fluxo End-to-End Workflow Guide

This guide demonstrates the complete Fluxo workflow from CLI to Studio plugin integration.

## 🚀 **Quick Start**

### Prerequisites
- Rust toolchain installed
- Roblox Studio installed
- Rojo installed (optional, for plugin building)

### 1. Build and Test
```bash
# Run integration test
./test-integration.sh  # Linux/Mac
# or
test-integration.bat   # Windows

# Build manually
cargo build --release
```

### 2. Install Studio Plugin
```bash
# Build the plugin
cd studio-plugin
rojo build --output FluxoPlugin.rbxmx

# Install in Studio:
# 1. Open Roblox Studio
# 2. Go to Plugins → Manage Plugins
# 3. Click "Install from file..."
# 4. Select FluxoPlugin.rbxmx
```

### 3. Create a New Plugin Project
```bash
# Initialize new project
fluxo init my-awesome-plugin --template plugin
cd my-awesome-plugin

# Validate project
fluxo validate
```

### 4. Start Development Server
```bash
# Start the server (runs on port 8080 for Argon, 9080 for Fluxo)
fluxo serve

# Should see:
# ✅ Serving on: http://localhost:8080, project: default.project.json
# ✅ Starting Fluxo HTTP server on: http://localhost:9080
```

### 5. Connect Studio Plugin
1. Open Roblox Studio
2. Click the "Fluxo Dashboard" button in the toolbar
3. The plugin should connect automatically and show "🟢 Connected"

### 6. Sync Your Code
```bash
# Sync files to Studio
fluxo sync

# Or sync with watch mode
fluxo sync --watch
```

In Studio, you should see:
- Files appear in the dashboard
- Sync status updates
- File change notifications

### 7. Validate Your Plugin
```bash
# Run validation
fluxo validate

# Or validate specific aspects
fluxo validate --skip-metadata
fluxo validate --verbose
```

### 8. Publish Your Plugin
```bash
# Publish with confirmation
fluxo publish --version 1.0.0 --notes "Initial release"

# Quick publish (skip confirmation)
fluxo publish --yes
```

In Studio:
- Publish confirmation modal appears
- Review metadata and settings
- Click "Publish" to upload to Roblox
- Plugin uses `Plugin:PublishAsPluginAsync()` for safe publishing

## 🔧 **Architecture Overview**

### CLI Components
- **HTTP Server** (`src/server/http.rs`): Warp-based server on port 9080
- **Commands**: `init`, `validate`, `sync`, `publish`, `serve`
- **Project Management**: File reading, metadata handling, validation

### Studio Plugin Components
- **Dashboard** (`studio-plugin/src/ui/Dashboard.lua`): Main UI
- **Core Modules**:
  - `Server.lua`: HTTP communication
  - `Sync.lua`: File synchronization with diff viewer
  - `Publish.lua`: Publishing with `Plugin:PublishAsPluginAsync()`
  - `Validation.lua`: Project validation reports
  - `MetadataEditor.lua`: Visual metadata editing
- **Utilities**: HTTP client, logging system

### Communication Flow
```
CLI (Port 9080) ←→ HTTP ←→ Studio Plugin
                         ↓
                   Roblox Publishing API
```

## 📁 **Project Structure**

```
my-plugin/
├── src/
│   ├── .src.server.luau      # Main plugin script
│   └── ToolbarUI.lua         # UI components
├── plugin.meta.json          # Plugin metadata
├── fluxo.config.json         # Fluxo configuration
├── README.md                 # Project documentation
└── selene.toml              # Linting configuration
```

## 🎯 **Key Features**

### ✅ **Implemented**
- [x] Complete CLI command suite
- [x] Studio plugin with modern UI
- [x] HTTP communication between CLI and Studio
- [x] File synchronization with diff viewer
- [x] Real publishing via `Plugin:PublishAsPluginAsync()`
- [x] Project validation with detailed reports
- [x] Metadata editing with form validation
- [x] Build system with Rojo integration
- [x] CI/CD pipeline with GitHub Actions

### 🚧 **In Progress**
- [ ] End-to-end testing with real Studio environment
- [ ] Error handling optimization
- [ ] Performance improvements
- [ ] Web dashboard implementation

## 🐛 **Troubleshooting**

### CLI Issues
- **"Cannot connect to Studio"**: Make sure Studio is open and the plugin is installed
- **"Port already in use"**: Stop other Fluxo instances or use `--port` flag
- **"Validation failed"**: Check project structure and fix reported issues

### Studio Plugin Issues
- **Plugin not appearing**: Reinstall the .rbxmx file and restart Studio
- **"Connection failed"**: Check if CLI server is running (`fluxo serve`)
- **Publish errors**: Verify metadata and check Studio output window

### Common Solutions
```bash
# Reset everything
pkill -f fluxo  # Stop all instances
rm -rf ~/.fluxo  # Clear cache (if exists)
fluxo serve  # Restart server

# Rebuild plugin
cd studio-plugin
rojo build --output FluxoPlugin.rbxmx
# Reinstall in Studio
```

## 📊 **Development Status**

| Component | Status | Notes |
|-----------|--------|-------|
| CLI Foundation | ✅ Complete | All commands implemented |
| HTTP Server | ✅ Complete | Warp-based with REST API |
| Studio Plugin | ✅ Complete | Full UI and core modules |
| Integration | 🚧 Testing | Ready for real-world testing |
| Web Dashboard | 🚧 Framework | Next.js structure created |
| CI/CD | ✅ Complete | GitHub Actions workflow |

## 🚀 **Next Steps**

1. **Test with Real Studio**: Complete end-to-end testing in Roblox Studio
2. **Polish UX**: Improve error messages and user feedback
3. **Web Dashboard**: Implement the web UI for team management
4. **Documentation**: Create comprehensive user guides
5. **Beta Release**: Prepare for community testing

The core functionality is complete and ready for integration testing!
