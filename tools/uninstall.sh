#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Print colorful message
print_step() {
    echo -e "${GREEN}🍜 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✨ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    print_error "Please run as root (use sudo)"
fi

print_step "Uninstalling Noodles..."

# Remove binary
if [ -f /usr/local/bin/noodles ]; then
    rm /usr/local/bin/noodles || print_error "Failed to remove Noodles binary"
fi

# Remove Go installation
if [ -d /usr/local/go ]; then
    rm -rf /usr/local/go || print_error "Failed to remove Go installation"
fi

# Remove Go environment setup
if [ -f /etc/profile.d/go.sh ]; then
    rm /etc/profile.d/go.sh || print_error "Failed to remove Go environment setup"
fi

print_success "Noodles has been uninstalled successfully! 🎉"