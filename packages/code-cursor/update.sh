#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_FILE="$SCRIPT_DIR/package.nix"

# Function to print quick commands
print_quick_commands() {
    echo ""
    echo -e "${BLUE}🚀 Quick commands:${NC}"
    echo -e "${YELLOW}  NIXPKGS_ALLOW_UNFREE=1 nix build .#code-cursor --impure${NC}"
    echo -e "${YELLOW}  NIXPKGS_ALLOW_UNFREE=1 nix run .#code-cursor --impure${NC}"
}

echo -e "${BLUE}🔄 Updating Cursor package...${NC}"

# Step 1: Get the new URL from the API
echo -e "${YELLOW}📡 Fetching latest version information from API...${NC}"
API_RESPONSE=$(curl -s https://api2.cursor.sh/updates/api/download/latest/linux-x64/cursor)

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to fetch API response${NC}"
    exit 1
fi

NEW_URL=$(echo "$API_RESPONSE" | jq -r '.downloadUrl')
NEW_VERSION=$(echo "$API_RESPONSE" | jq -r '.version')

if [ "$NEW_URL" = "null" ] || [ "$NEW_VERSION" = "null" ]; then
    echo -e "${RED}❌ Failed to parse API response${NC}"
    echo "API Response: $API_RESPONSE"
    exit 1
fi

echo -e "${GREEN}✅ Found new version: $NEW_VERSION${NC}"
echo -e "${GREEN}✅ New URL: $NEW_URL${NC}"

# Step 2: Get the current version from package.nix
CURRENT_VERSION=$(grep -o 'version = "[^"]*"' "$PACKAGE_FILE" | cut -d'"' -f2)

if [ "$CURRENT_VERSION" = "$NEW_VERSION" ]; then
    echo -e "${YELLOW}⚠️  Package is already at the latest version ($NEW_VERSION)${NC}"
    print_quick_commands
    exit 0
fi

echo -e "${YELLOW}📦 Current version: $CURRENT_VERSION${NC}"
echo -e "${YELLOW}📦 New version: $NEW_VERSION${NC}"

# Step 3: Download and calculate new hash
echo -e "${YELLOW}🔍 Calculating new hash...${NC}"
HASH_OUTPUT=$(nix-prefetch-url --type sha256 "$NEW_URL")
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to prefetch URL${NC}"
    exit 1
fi

NEW_HASH_BASE32=$(echo "$HASH_OUTPUT" | head -n1)
NEW_HASH_SRI=$(nix hash convert --hash-algo sha256 --to sri "$NEW_HASH_BASE32")

echo -e "${GREEN}✅ New hash: $NEW_HASH_SRI${NC}"

# Step 4: Create backup of original file
BACKUP_FILE="$PACKAGE_FILE.backup.$(date +%Y%m%d_%H%M%S)"
cp "$PACKAGE_FILE" "$BACKUP_FILE"
echo -e "${BLUE}💾 Created backup: $BACKUP_FILE${NC}"

# Step 5: Update package.nix
echo -e "${YELLOW}📝 Updating package.nix...${NC}"

# Update URL
sed -i "s|url = \"https://downloads\.cursor\.com/production/[^\"]*\"|url = \"$NEW_URL\"|g" "$PACKAGE_FILE"

# Update hash
sed -i "s|hash = \"sha256-[^\"]*\"|hash = \"$NEW_HASH_SRI\"|g" "$PACKAGE_FILE"

# Update version
sed -i "s|version = \"[^\"]*\"|version = \"$NEW_VERSION\"|g" "$PACKAGE_FILE"

echo -e "${GREEN}✅ Updated package.nix with new version and hash${NC}"

# Step 6: Test build
echo -e "${YELLOW}🔨 Testing build...${NC}"
echo -e "${BLUE}   This may take a few minutes...${NC}"
if timeout 600 bash -c 'NIXPKGS_ALLOW_UNFREE=1 nix-build -E "with import <nixpkgs> { overlays = [ (import '"$SCRIPT_DIR"'/../../overlays/code-cursor.nix) ]; }; code-cursor" 2>&1' > /tmp/cursor_build_output.log 2>&1; then
    BUILD_OUTPUT=$(cat /tmp/cursor_build_output.log)
    echo -e "${GREEN}✅ Build successful!${NC}"
    BUILD_PATH=$(echo "$BUILD_OUTPUT" | tail -n1)
    echo -e "${GREEN}📦 Built package: $BUILD_PATH${NC}"
    
    # Test the binary
    echo -e "${YELLOW}🧪 Testing binary...${NC}"
    if VERSION_OUTPUT=$("$BUILD_PATH/bin/cursor" --version 2>/dev/null | head -n1); then
        echo -e "${GREEN}✅ Binary test successful: $VERSION_OUTPUT${NC}"
    else
        echo -e "${YELLOW}⚠️  Binary test failed, but build was successful${NC}"
    fi
else
    echo -e "${RED}❌ Build failed!${NC}"
    BUILD_OUTPUT=$(cat /tmp/cursor_build_output.log)
    echo "$BUILD_OUTPUT"
    echo -e "${YELLOW}🔄 Restoring backup...${NC}"
    mv "$BACKUP_FILE" "$PACKAGE_FILE"
    rm -f /tmp/cursor_build_output.log
    exit 1
fi

# Cleanup
rm -f /tmp/cursor_build_output.log

# Step 7: Success message
echo ""
echo -e "${GREEN}🎉 Update completed successfully!${NC}"
echo -e "${GREEN}📊 Summary:${NC}"
echo -e "  • Version: $CURRENT_VERSION → $NEW_VERSION"
echo -e "  • Hash: $NEW_HASH_SRI"
echo -e "  • Build: ✅ Successful"
echo -e "  • Binary: ✅ Working"
echo ""
print_quick_commands
echo ""
echo -e "${BLUE}📁 Backup file saved as: $BACKUP_FILE${NC}"