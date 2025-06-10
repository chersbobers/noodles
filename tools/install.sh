#!/bin/bash

set -e

# Colors and emojis for pretty output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colorful message
print_header() {
    echo -e "${YELLOW}"
    echo '🍜 Noodles - MPR Helper'
    echo '======================='
    echo -e "${NC}"
}

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
    case "$ARCH" in
        "x86_64"|"amd64")
            ARCH="amd64"
            ;;
        "aarch64"|"arm64")
            ARCH="arm64"
            ;;
        *)
            print_error "Unsupported architecture: $ARCH. Only x86_64/amd64 and arm64/aarch64 are supported."
            ;;
    esac

    # Check for required commands
    if ! command_exists curl; then
        apt-get update && apt-get install -y curl || print_error "Failed to install curl"
    fi

    if ! command_exists git; then
        apt-get update && apt-get install -y git || print_error "Failed to install git"
    fi
}

# Install makedeb
install_makedeb() {
    print_step "Installing makedeb..."
    
    # Install makedeb prerequisites
    apt-get update
    apt-get install -y sudo wget
    
    # Import makedeb GPG key
    wget -qO - 'https://proget.makedeb.org/debian-feeds/makedeb.pub' | gpg --dearmor | sudo tee /usr/share/keyrings/makedeb-archive-keyring.gpg 1> /dev/null
    
    # Add makedeb repository
    echo 'deb [signed-by=/usr/share/keyrings/makedeb-archive-keyring.gpg arch=all] https://proget.makedeb.org/ makedeb main' | sudo tee /etc/apt/sources.list.d/makedeb.list
    
    # Install makedeb
    apt-get update
    apt-get install -y makedeb

    if ! command_exists makedeb; then
        print_error "Failed to install makedeb"
    fi
    
    print_success "makedeb installed successfully"
}

# Install Go 1.24.4
install_go() {
    print_step "Installing Go 1.24.4..."
    
    GO_VERSION="1.24.4"
    GO_TARBALL="go${GO_VERSION}.linux-${ARCH}.tar.gz"
    GO_URL="https://go.dev/dl/${GO_TARBALL}"
    
    # Download Go
    curl -fsSL "$GO_URL" -o "/tmp/${GO_TARBALL}" || print_error "Failed to download Go"
    
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
    git clone --depth=1 https://github.com/chersbobers/noodles.git || print_error "Failed to clone Noodles repository"
    cd noodles
    
    # Build Noodles
    GOARCH=$ARCH /usr/local/go/bin/go build -o noodles || print_error "Failed to build Noodles"
    
    # Install binary
    mv noodles /usr/local/bin/ || print_error "Failed to install Noodles binary"
    chmod +x /usr/local/bin/noodles
    
    # Cleanup
    cd
    rm -rf "$TMP_DIR"
    
    print_success "Noodles installed successfully!"
}

main() {
    print_header
    
    echo -e "${BLUE}This script will install:${NC}"
    echo "  • makedeb directly from the official repository"
    echo "  • Go 1.24.4"
    echo "  • Noodles MPR Helper"
    echo
    
    # Prompt for confirmation
    echo -e "${YELLOW}Ready to install? [Y/n]${NC} "
    read -r response
    if [[ "$response" =~ ^[Nn] ]]; then
        echo "Installation cancelled."
        exit 1
    fi
    
    check_requirements
    install_makedeb
    install_go
    install_noodles
    
    print_success "Installation complete! 🎉"
    echo
    echo -e "${GREEN}You can now use Noodles by running: ${BLUE}noodles install <package-name>${NC}"
}

main