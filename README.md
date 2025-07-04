# Fluxo

Fluxo is a next-generation Roblox plugin development tool that streamlines syncing, validation, and publishing workflows. Built from the Argon codebase, it provides a complete development experience with both CLI and Studio companion tools.

## 🚀 Current Status

**✅ CLI Foundation**
- ✅ Rebranded from Argon to Fluxo
- ✅ Updated CLI structure with new commands (`validate`, `sync`, `publish`)
- ✅ Enhanced plugin templates with proper metadata and configuration
- ✅ Fixed linting issues in templates with proper selene configuration

**✅ Studio Plugin**
- ✅ Complete plugin architecture with modular design
- ✅ Dashboard UI with project management and logging
- ✅ HTTP communication system for CLI interaction
- ✅ Publishing modal with metadata editing
- ✅ File synchronization with diff viewer
- ✅ Project validation with detailed reporting
- ✅ Comprehensive logging system

**🚧 Integration** (Next Phase)
- 🚧 Real HTTP server implementation in CLI
- 🚧 End-to-end sync and publish testing
- 🚧 Error handling and edge cases
- 🚧 Performance optimizations

## 🏗️ Architecture

### CLI Tool (`src/`)
- **Commands**: `init`, `build`, `serve`, `validate`, `sync`, `publish`
- **Templates**: Enhanced plugin templates with metadata and config
- **Core**: File processing, project management, and HTTP server

### Studio Plugin (`studio-plugin/`)
- **Dashboard**: Main UI for project management
- **Core Modules**: Server, Publish, Sync, Validation, MetadataEditor
- **Utilities**: HTTP client, logging system
- **Build System**: Rojo-based plugin compilation

## 🛠️ Features

- **File Synchronization**: Safe, one-way sync from CLI to Studio
- **Publishing**: Secure plugin publishing with Studio confirmation
- **Validation**: Project structure and code validation
- **Metadata Management**: Visual metadata editor with form validation
- **Templates**: Ready-to-use plugin templates with best practices
- **Logging**: Comprehensive logging with multiple levels
- **HTTP API**: RESTful communication between CLI and Studio

## 📦 Installation

### CLI Tool
```bash
cargo build --release
# Binary will be available in target/release/
```

### Studio Plugin
```bash
# Build the plugin
cd studio-plugin
rojo build --output Fluxo.rbxmx

# Install in Studio via Plugin Manager
```

## � Quick Start

1. **Initialize a new plugin project**:
   ```bash
   fluxo init my-plugin --template plugin
   ```

2. **Start development server**:
   ```bash
   cd my-plugin
   fluxo serve
   ```

3. **Open Studio and install the Fluxo companion plugin**

4. **Use the Dashboard to sync and manage your project**

## 📁 Project Structure

```
my-plugin/
├── plugin.meta.json      # Plugin metadata
├── fluxo.config.json     # Fluxo configuration
├── src/
│   ├── .src.server.luau  # Main plugin script
│   └── ToolbarUI.lua     # UI components
├── README.md
└── selene.toml          # Linting configuration
```

## 🔧 Configuration

### fluxo.config.json
```json
{
  "name": "MyPlugin",
  "sync": {
    "include": ["src/**/*.lua", "src/**/*.luau"],
    "exclude": ["**/*.spec.lua"]
  },
  "validation": {
    "strict": true,
    "checkNaming": true
  }
}
```

## 📚 Documentation

- See `PRD.md` for the complete product roadmap
- Check `studio-plugin/README.md` for Studio plugin details
- Template documentation in `assets/templates/plugin/TEMPLATE_README.md`

## 🤝 Contributing

Fluxo is actively under development. The core architecture is complete and we're working on integration testing and polish.

## 📄 License

See LICENSE.md for details.

## 🧪 **Testing the Integration**

### Quick Integration Test
```bash
# Run the automated integration test
./test-integration.sh    # Linux/Mac
test-integration.bat     # Windows
```

### Manual Testing Steps
1. **Build and install**:
   ```bash
   cargo build --release
   cd studio-plugin && rojo build --output FluxoPlugin.rbxmx
   ```

2. **Create test project**:
   ```bash
   fluxo init test-plugin --template plugin
   cd test-plugin
   ```

3. **Start development server**:
   ```bash
   fluxo serve
   # Server runs on port 8080 (Argon) and 9080 (Fluxo HTTP)
   ```

4. **Install Studio plugin**:
   - Open Roblox Studio
   - Install FluxoPlugin.rbxmx via Plugin Manager
   - Click "Fluxo Dashboard" in toolbar

5. **Test sync workflow**:
   ```bash
   fluxo sync --watch
   # Edit files in src/ and see them sync to Studio
   ```

6. **Test publish workflow**:
   ```bash
   fluxo publish --version 1.0.0 --notes "Test release"
   # Confirm in Studio's publish dialog
   ```

## 🔗 **HTTP API Endpoints**

The CLI server exposes these endpoints for Studio communication:

- `GET /health` - Health check
- `POST /sync` - Sync files to Studio  
- `POST /validate` - Validate project
- `POST /publish` - Trigger publish flow

All endpoints run on `http://localhost:9080` by default.
