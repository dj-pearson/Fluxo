#!/bin/bash
# Build script for Fluxo Studio Plugin

echo "Building Fluxo Studio Plugin..."

# Check if rojo is installed
if ! command -v rojo &> /dev/null; then
    echo "Error: Rojo is not installed. Please install it first:"
    echo "  cargo install rojo"
    exit 1
fi

# Build the plugin
rojo build studio-plugin --output Fluxo.rbxmx

if [ $? -eq 0 ]; then
    echo "✅ Plugin built successfully: Fluxo.rbxmx"
    echo ""
    echo "To install in Studio:"
    echo "1. Open Roblox Studio"
    echo "2. Go to Plugins → Manage Plugins"
    echo "3. Click 'Install from file...'"
    echo "4. Select Fluxo.rbxmx"
else
    echo "❌ Build failed"
    exit 1
fi
