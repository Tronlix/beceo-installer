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

# Step 1: Download BeCEO package from latest release
step "Step 1: Downloading BeCEO"
TGZ_PATH="/tmp/beceo-install.tgz"
LATEST_TGZ_URL=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
    | grep "browser_download_url" \
    | grep "\.tgz" \
    | head -1 \
    | cut -d '"' -f 4)

if [ -z "$LATEST_TGZ_URL" ]; then
    fail "Could not find BeCEO package in latest release. Please check https://github.com/$REPO/releases"
fi

echo "   Downloading from $LATEST_TGZ_URL..."
curl -fsSL "$LATEST_TGZ_URL" -o "$TGZ_PATH"
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
npm install -g "$TGZ_PATH"
rm -f "$TGZ_PATH"
ok "BeCEO installed successfully"

# Step 5: Initial setup
step "Step 5: Initial Setup"
echo ""
echo "   Starting BeCEO setup wizard..."
echo "   Please follow the prompts to complete your configuration."
echo ""
sleep 1

beceo setup || warn "Setup failed or was skipped. Run 'beceo setup' manually to configure."

echo ""
echo "  +==================================+"
echo "  |   Installation Complete! 🎉      |"
echo "  |                                  |"
echo "  |  To start BeCEO, run:            |"
echo "  |     beceo start                  |"
echo "  +==================================+"
echo ""
