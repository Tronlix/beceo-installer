#!/bin/bash
# BeCEO macOS Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/Tronlix/beceo-installer/main/mac/install.sh | bash

set -e

REPO="Tronlix/beceo-installer"
NODE_MIN_VERSION=22

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

step() { echo -e "\n${CYAN}>> $1${NC}"; }
ok()   { echo -e "   ${GREEN}[OK]${NC} $1"; }
warn() { echo -e "   ${YELLOW}[WARN]${NC} $1"; }
fail() { echo -e "\n   ${RED}[ERROR]${NC} $1\n"; exit 1; }

clear
echo ""
echo "  +==================================+"
echo "  |        BeCEO Installer           |"
echo "  +==================================+"
echo ""

# Step 1: Download BeCEO package
step "Step 1: Downloading BeCEO"
TGZ_PATH="/tmp/beceo-install.tgz"
TGZ_URL="https://raw.githubusercontent.com/$REPO/main/beceo-V1Beta.tgz"

echo "   Downloading BeCEO package..."
curl -fsSL "$TGZ_URL" -o "$TGZ_PATH" || fail "Could not download BeCEO package. Please check your internet connection."
ok "Downloaded BeCEO package"

# Step 2: Check Homebrew
step "Step 2: Checking Homebrew"
if ! command -v brew &>/dev/null; then
    echo "   Installing Homebrew (this may take a few minutes)..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    fi
    ok "Homebrew installed"
else
    ok "Homebrew is already installed"
fi

# Step 3: Check Node.js
step "Step 3: Checking Node.js"
NODE_OK=false
if command -v node &>/dev/null; then
    NODE_VER=$(node --version | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_VER" -ge "$NODE_MIN_VERSION" ]; then
        ok "Node.js $(node --version) is already installed"
        NODE_OK=true
    else
        echo "   Node.js $(node --version) is too old (need v${NODE_MIN_VERSION}+), upgrading..."
    fi
fi

if [ "$NODE_OK" = false ]; then
    echo "   Installing Node.js v${NODE_MIN_VERSION}..."
    brew install node@${NODE_MIN_VERSION}
    brew link --overwrite node@${NODE_MIN_VERSION} 2>/dev/null || true
    export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
    ok "Node.js installed"
fi

# Step 4: Install BeCEO
step "Step 4: Installing BeCEO"
echo "   Running npm install (this may take a few minutes)..."
npm install -g "$TGZ_PATH" </dev/null
NPM_EXIT=$?
rm -f "$TGZ_PATH"
if [ $NPM_EXIT -ne 0 ]; then
    fail "npm install failed (exit code $NPM_EXIT). Please check your Node.js installation or network connection."
fi
ok "BeCEO installed successfully"

# Step 5: Initial setup
step "Step 5: Initial Setup"
echo ""
echo "   Installation complete! Now run the setup wizard:"
echo ""
echo "     beceo setup"
echo ""
echo "  +==================================+"
echo "  |   Installation Complete! 🎉      |"
echo "  |                                  |"
echo "  |  Run the following to configure: |"
echo "  |     beceo setup                  |"
echo "  |                                  |"
echo "  |  Then start BeCEO with:          |"
echo "  |     beceo start                  |"
echo "  +==================================+"
echo ""
