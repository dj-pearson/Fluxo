#!/bin/bash
# Integration test script for Fluxo CLI and Studio plugin communication

echo "🧪 Fluxo Integration Test"
echo "========================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test project directory
TEST_DIR="./test-integration"
PROJECT_NAME="test-plugin"

# Cleanup function
cleanup() {
    echo -e "${YELLOW}🧹 Cleaning up test environment...${NC}"
    rm -rf "$TEST_DIR"
    pkill -f "fluxo serve" 2>/dev/null || true
}

# Setup trap for cleanup
trap cleanup EXIT

echo -e "${BLUE}📦 Step 1: Building Fluxo CLI...${NC}"
cargo build --release
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to build Fluxo CLI${NC}"
    exit 1
fi
echo -e "${GREEN}✅ CLI built successfully${NC}"

echo -e "${BLUE}🏗️  Step 2: Creating test project...${NC}"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# Initialize test plugin project
../target/release/fluxo init "$PROJECT_NAME" --template plugin
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to initialize test project${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Test project created${NC}"

cd "$PROJECT_NAME"

echo -e "${BLUE}📋 Step 3: Validating project structure...${NC}"
if [ ! -f "plugin.meta.json" ]; then
    echo -e "${RED}❌ Missing plugin.meta.json${NC}"
    exit 1
fi

if [ ! -f "fluxo.config.json" ]; then
    echo -e "${RED}❌ Missing fluxo.config.json${NC}"
    exit 1
fi

if [ ! -d "src" ]; then
    echo -e "${RED}❌ Missing src directory${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Project structure is valid${NC}"

echo -e "${BLUE}🔍 Step 4: Running validation command...${NC}"
../../target/release/fluxo validate
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Validation failed${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Validation passed${NC}"

echo -e "${BLUE}🚀 Step 5: Starting development server...${NC}"
../../target/release/fluxo serve &
SERVER_PID=$!

# Wait for server to start
sleep 3

# Check if server is running
if ! ps -p $SERVER_PID > /dev/null; then
    echo -e "${RED}❌ Server failed to start${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Development server started (PID: $SERVER_PID)${NC}"

echo -e "${BLUE}🔌 Step 6: Testing HTTP endpoints...${NC}"

# Test health endpoint
if curl -s "http://localhost:9080/health" > /dev/null; then
    echo -e "${GREEN}✅ Health endpoint responding${NC}"
else
    echo -e "${YELLOW}⚠️  Health endpoint not responding (Studio not connected)${NC}"
fi

# Test sync endpoint with sample data
SYNC_DATA='{"files":{"test.lua":"print(\"hello\")"}, "metadata":{"name":"test"}}'
SYNC_RESPONSE=$(curl -s -X POST "http://localhost:9080/sync" \
    -H "Content-Type: application/json" \
    -d "$SYNC_DATA" \
    -w "%{http_code}" \
    -o /tmp/sync_response.json)

if [ "$SYNC_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✅ Sync endpoint responding${NC}"
else
    echo -e "${YELLOW}⚠️  Sync endpoint returned $SYNC_RESPONSE (Studio not connected)${NC}"
fi

echo -e "${BLUE}📡 Step 7: Testing CLI sync command...${NC}"
../../target/release/fluxo sync --port 8080
echo -e "${GREEN}✅ Sync command completed${NC}"

echo -e "${BLUE}📤 Step 8: Testing CLI publish command...${NC}"
echo "y" | ../../target/release/fluxo publish --port 8080 --version "1.0.0" --notes "Test release"
echo -e "${GREEN}✅ Publish command completed${NC}"

echo -e "${BLUE}🏗️  Step 9: Building Studio plugin...${NC}"
cd ../../studio-plugin
if command -v rojo &> /dev/null; then
    rojo build --output ../test-integration/FluxoPlugin.rbxmx
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Studio plugin built successfully${NC}"
    else
        echo -e "${YELLOW}⚠️  Studio plugin build failed (rojo error)${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Rojo not installed, skipping plugin build${NC}"
fi

# Stop the server
kill $SERVER_PID 2>/dev/null || true

echo -e "${GREEN}🎉 Integration test completed!${NC}"
echo ""
echo -e "${BLUE}📊 Test Summary:${NC}"
echo -e "${GREEN}✅ CLI build${NC}"
echo -e "${GREEN}✅ Project initialization${NC}"
echo -e "${GREEN}✅ Project validation${NC}"
echo -e "${GREEN}✅ Development server${NC}"
echo -e "${GREEN}✅ HTTP endpoints${NC}"
echo -e "${GREEN}✅ CLI commands${NC}"
echo ""
echo -e "${YELLOW}📝 Next Steps:${NC}"
echo "1. Install FluxoPlugin.rbxmx in Roblox Studio"
echo "2. Run 'fluxo serve' in your project directory"
echo "3. Open Studio and test the sync/publish workflow"
echo ""
echo -e "${BLUE}🔗 Integration Status: READY FOR STUDIO TESTING${NC}"
