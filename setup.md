# 🚀 Complete Fluxo Testing Setup Guide

## **Prerequisites Installation**

### **1. Install Visual Studio Build Tools (Required)**

**Download & Install:**
1. Go to: https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022
2. Download "Build Tools for Visual Studio 2022"
3. Run the installer

**During Installation, Select:**
- ✅ **C++ build tools** (under "Desktop development with C++")
- ✅ **Windows 10/11 SDK** (latest version)
- ✅ **CMake tools for C++**
- ✅ **MSVC v143 - VS 2022 C++ x64/x86 build tools**

**Time Required:** ~15-20 minutes

### **2. Install Rust (If Not Already Installed)**

```powershell
# Download and install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Or visit: https://rustup.rs/
```

### **3. Install Optional Tools**

**For Studio Plugin Building:**
```powershell
# Install Rojo (Roblox project manager)
cargo install rojo
```

**For Web Dashboard (Future):**
```powershell
# Install Node.js from: https://nodejs.org/
# Or use winget:
winget install OpenJS.NodeJS
```

---

## **Step 2: Verify Build Environment**

After installing Build Tools, restart your terminal and run:

```powershell
cd "c:\Users\pears\OneDrive\Documents\Fluxo"
.\setup-environment.bat
```

**Expected Output:**
```
🔧 Fluxo Build Environment Setup
===============================
✅ Visual Studio Build Tools: FOUND
✅ C++ Compiler: WORKING
✅ Rust/Cargo: FOUND
✅ Rojo: FOUND (optional)
⚠️  Node.js: NOT FOUND (needed for web dashboard)

🎉 Build environment ready!
```

---

## **Step 3: Build Fluxo CLI**

### **3.1 Clean Build**
```powershell
# Clean any previous build artifacts
cargo clean

# Build in release mode (optimized)
cargo build --release
```

**Expected Time:** 5-10 minutes (first build)

**Expected Output:**
```
   Compiling fluxo v2.0.0
    Finished release [optimized] target(s) in 8m 32s
```

### **3.2 Verify CLI Commands**
```powershell
# Test basic CLI functionality
./target/release/fluxo.exe --version
./target/release/fluxo.exe --help
```

---

## **Step 4: Build Studio Plugin**

### **4.1 Build Plugin File**
```powershell
cd studio-plugin

# Build the plugin (requires Rojo)
rojo build --output FluxoPlugin.rbxmx

# Alternative: Use build script
.\build.bat
```

**Expected Output:**
```
✅ FluxoPlugin.rbxmx created successfully
```

### **4.2 Verify Plugin Files**
```powershell
# Check if plugin was built
ls FluxoPlugin.rbxmx

# Check plugin structure
rojo sourcemap --output sourcemap.json
```

---

## **Step 5: Create Test Project**

### **5.1 Initialize Test Project**
```powershell
cd "c:\Users\pears\OneDrive\Documents"

# Create test plugin project
./Fluxo/target/release/fluxo.exe init test-plugin --template plugin
cd test-plugin
```

**Expected Structure:**
```
test-plugin/
├── src/
│   └── .src.server.luau
├── plugin.meta.json
├── fluxo.config.json
├── project.json
└── selene.toml
```

### **5.2 Validate Test Project**
```powershell
# Validate the project
../Fluxo/target/release/fluxo.exe validate

# Expected output: No issues found
```

---

## **Step 6: Test Fluxo CLI Server**

### **6.1 Start Fluxo Server**
```powershell
# Start the dual server (Argon + Fluxo HTTP)
../Fluxo/target/release/fluxo.exe serve
```

**Expected Output:**
```
🚀 Serving on: http://127.0.0.1:8080, project: test-plugin\project.json
🚀 Starting Fluxo HTTP server on: http://127.0.0.1:9080
🚀 Fluxo HTTP server starting on port 9080
```

### **6.2 Test HTTP Endpoints**

**Open a new terminal and test:**
```powershell
# Health check
curl http://localhost:9080/health

# Expected: {"status":"ok","service":"fluxo-cli"}

# Sync test
curl -X POST http://localhost:9080/sync -H "Content-Type: application/json" -d "{}"

# Validate test
curl -X POST http://localhost:9080/validate -H "Content-Type: application/json" -d "{}"
```

---

## **Step 7: Install Studio Plugin**

### **7.1 Install in Roblox Studio**
1. **Open Roblox Studio**
2. **Go to:** Plugins → Manage Plugins
3. **Click:** "Install from file..."
4. **Select:** `FluxoPlugin.rbxmx` from studio-plugin folder
5. **Click:** Install

### **7.2 Verify Plugin Installation**
1. **Check Toolbar:** Look for "Fluxo Dashboard" button
2. **Click Button:** Should open Fluxo dashboard UI
3. **Check Console:** Should see "Fluxo Plugin Loaded" message

---

## **Step 8: Test End-to-End Workflow**

### **8.1 Studio → CLI Communication**

**In Studio:**
1. Click "Fluxo Dashboard" button
2. Click "Sync Files" button
3. Check dashboard for file list

**In CLI Terminal:**
- Should see HTTP requests in server logs
- Files should be listed in Studio dashboard

### **8.2 File Validation Test**

**In Studio:**
1. Click "Validate Project" 
2. Review validation report
3. Check for any issues or warnings

### **8.3 Publishing Test (Dry Run)**

**In Studio:**
1. Fill out plugin metadata
2. Click "Publish Plugin" 
3. Review publishing confirmation dialog
4. **Don't actually publish** (just test the flow)

---

## **Step 9: Automated Integration Test**

### **9.1 Run Full Integration Test**
```powershell
cd "c:\Users\pears\OneDrive\Documents\Fluxo"

# Run automated integration test
.\test-integration.bat
```

**Expected Output:**
```
🧪 Fluxo Integration Test
========================
✅ CLI build successful
✅ HTTP server responsive  
✅ Plugin build successful
✅ Project validation working
✅ File sync operational
🎉 All tests passed!
```

---

## **Troubleshooting Common Issues**

### **Build Errors**
```powershell
# If you get linker errors:
# 1. Restart terminal after installing Build Tools
# 2. Run setup-environment.bat again
# 3. Try clean rebuild:
cargo clean
cargo build --release
```

### **Port Conflicts**
```powershell
# If ports 8080/9080 are in use:
# Fluxo will automatically scan for free ports
# Or specify custom ports:
fluxo serve --port 8081  # Will use 8081 + 9081
```

### **Studio Plugin Issues**
```powershell
# If plugin doesn't load:
# 1. Check Studio's Output console for errors
# 2. Verify plugin file exists and is not corrupted
# 3. Try rebuilding plugin:
cd studio-plugin
rojo build --output FluxoPlugin.rbxmx
```

### **Selene/Linting Errors**
```powershell
# If you see "Instance is not defined" errors:
# 1. Ensure VS Code has the Selene extension installed
# 2. Check that selene.toml has std = "roblox"
# 3. Restart VS Code language server:
# Ctrl+Shift+P -> "Developer: Reload Window"
# 4. Or disable Selene temporarily in VS Code settings
```

### **HTTP Connection Issues**
```powershell
# If Studio can't connect to CLI:
# 1. Check Windows Firewall
# 2. Verify ports are open:
netstat -an | findstr :9080
# 3. Test localhost connection:
curl http://localhost:9080/health
```

---

## **Success Checklist**

Before considering Fluxo ready for production use:

### **✅ Build Environment**
- [ ] Visual Studio Build Tools installed
- [ ] Rust toolchain working
- [ ] Cargo build succeeds without errors
- [ ] Rojo available for plugin building

### **✅ CLI Functionality**  
- [ ] `fluxo --version` works
- [ ] `fluxo init` creates projects
- [ ] `fluxo serve` starts both servers
- [ ] HTTP endpoints respond correctly

### **✅ Studio Integration**
- [ ] Plugin installs without errors
- [ ] Dashboard UI opens and functions
- [ ] HTTP communication works
- [ ] File sync displays correctly

### **✅ End-to-End Workflow**
- [ ] Project validation reports issues
- [ ] File synchronization works both ways
- [ ] Publishing flow completes (dry run)
- [ ] Error handling works gracefully

---

## **🎯 Quick Summary**

### **Essential Steps:**
1. **Install Visual Studio Build Tools** (15-20 min)
2. **Build Fluxo**: `cargo build --release` (5-10 min)
3. **Build Plugin**: `rojo build --output FluxoPlugin.rbxmx` (2 min)
4. **Install Plugin** in Roblox Studio (2 min)
5. **Test Workflow**: CLI server + Studio dashboard (5 min)

### **🚀 Quick Start Commands**
```powershell
# 1. Install build tools (manual step)
# 2. Build Fluxo
cargo build --release

# 3. Test everything
.\test-integration.bat
```

**Estimated Time**: ~60 minutes total (mostly waiting for build tools installation)

**Main Blocker**: Visual Studio Build Tools installation - everything else is automated!

---

## **Next Steps After Testing**

Once everything is working:

1. **Alpha Testing:** Share with a small group of developers
2. **Web Dashboard:** Implement Next.js dashboard features  
3. **CI/CD:** Test GitHub Actions workflow
4. **Documentation:** Create user guides and tutorials
5. **Beta Release:** Package for wider community testing

**The implementation is complete and ready for testing once the build environment is set up!** 🎊

---

## **⚠️ Common Issues & Solutions**

### **Selene Linting Errors in VS Code**

If you see many red errors like "`Instance` is not defined" in VS Code:

**Quick Fix:**
```powershell
# Run the fix script
.\fix-selene.bat

# Or manually restart VS Code language server:
# Ctrl+Shift+P -> "Developer: Reload Window"
```

**Root Cause:** VS Code's Selene extension may not be reading the Roblox standard library configuration properly.

**Alternative Solutions:**
1. Install the Selene VS Code extension if not already installed
2. Restart VS Code completely
3. Temporarily disable Selene in VS Code settings if needed for testing