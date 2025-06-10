#!/bin/bash

set -e

# Colors and emojis for pretty output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print colorful message
print_step() {
    echo -e "${BLUE}🍜 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✨ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check system requirements
check_requirements() {
    print_step "Checking system requirements..."

    # Check if running as root
    if [ "$EUID" -ne 0 ]; then 
        print_error "Please run as root (use sudo)"
    fi

    # Check architecture
    ARCH=$(uname -m)
    if [ "$ARCH" != "x86_64" ]; then
        print_error "Only x86_64 architecture is supported currently"
    fi

    # Check for required commands
    if ! command_exists wget; then
        apt-get update && apt-get install -y wget || print_error "Failed to install wget"
    fi

    if ! command_exists git; then
        apt-get update && apt-get install -y git || print_error "Failed to install git"
    fi
}

# Install makedeb if not present
install_makedeb() {
    print_step "Checking makedeb installation..."
    
    if ! command_exists makedeb; then
        print_step "Installing makedeb..."
        bash -c "$(wget -qO - 'https://shlink.makedeb.org/install')" || print_error "Failed to install makedeb"
    fi
    
    print_success "makedeb is installed"
}

# Install Go 1.24.4
install_go() {
    print_step "Installing Go 1.24.4..."
    
    GO_VERSION="1.24.4"
    GO_TARBALL="go${GO_VERSION}.linux-amd64.tar.gz"
    GO_URL="https://go.dev/dl/${GO_TARBALL}"
    
    # Download Go
    wget -q "$GO_URL" -O "/tmp/${GO_TARBALL}" || print_error "Failed to download Go"
    
    # Remove existing Go installation if present
    rm -rf /usr/local/go
    
    # Extract Go to /usr/local
    tar -C /usr/local -xzf "/tmp/${GO_TARBALL}" || print_error "Failed to extract Go"
    rm "/tmp/${GO_TARBALL}"
    
    # Set up Go environment
    echo 'export PATH=$PATH:/usr/local/go/bin' > /etc/profile.d/go.sh
    source /etc/profile.d/go.sh
    
    print_success "Go ${GO_VERSION} installed successfully"
}

# Install Noodles
install_noodles() {
    print_step "Installing Noodles..."
    
    # Create temporary directory
    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR"
    
    # Clone repository
    git clone https://github.com/chersbobers/noodles.git || print_error "Failed to clone Noodles repository"
    cd noodles
    
    # Build Noodles
    /usr/local/go/bin/go build -o noodles || print_error "Failed to build Noodles"
    
    # Install binary
    mv noodles /usr/local/bin/ || print_error "Failed to install Noodles binary"
    chmod +x /usr/local/bin/noodles
    
    # Cleanup
    cd
    rm -rf "$TMP_DIR"
    
    print_success "Noodles installed successfully!"
}

# Main installation flow
main() {
    print_step "Starting Noodles installation..."
    
    check_requirements
    install_makedeb
    install_go
    install_noodles
    
    print_success "Installation complete! 🎉"
    echo -e "${GREEN}You can now use Noodles by running: ${BLUE}noodles install <package-name>${NC}"
}

# Run main installation
main
