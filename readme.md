# Noodles 🍜

A quick 'n' simple mpr helper for the best

## Quick Install

Install Noodles with this simple command:

```bash
sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/chersbobers/noodles/main/tools/install.sh)"
```

Or with wget:

```bash
sudo sh -c "$(wget -qO- https://raw.githubusercontent.com/chersbobers/noodles/main/tools/install.sh)"
```

The install script will automatically:
1. Install makedeb and its dependencies
2. Install Go 1.24.4
3. Build and install Noodles

## Usage

Install a package from MPR:

```bash
noodles install <package-name>
```

Example:
```bash
noodles install spotify
```

## Features

- 🚀 Fast and lightweight
- 🔄 Automatic dependency resolution
- 📦 Easy package installation from MPR
- 🛠️ Built with Go for performance
- 🔍 Package information lookup

## Manual Installation

If you prefer to install manually:

1. Install makedeb:
```bash
# Import makedeb GPG key
wget -qO - 'https://proget.makedeb.org/debian-feeds/makedeb.pub' | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/makedeb-archive-keyring.gpg 1> /dev/null

# Add makedeb repository
echo 'deb [signed-by=/usr/share/keyrings/makedeb-archive-keyring.gpg arch=all] https://proget.makedeb.org/ makedeb main' | \
  sudo tee /etc/apt/sources.list.d/makedeb.list

# Install makedeb
sudo apt update
sudo apt install makedeb
```

2. Install Go 1.24.4:
```bash
curl -fsSL https://go.dev/dl/go1.24.4.linux-amd64.tar.gz -o go1.24.4.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.24.4.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
```

3. Clone and build Noodles:
```bash
git clone https://github.com/chersbobers/noodles.git
cd noodles
go build
sudo mv noodles /usr/local/bin/
```

## Uninstalling

To uninstall Noodles:

```bash
sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/chersbobers/noodles/main/tools/uninstall.sh)"
```

## Contributing

Contributions are welcome! Feel free to submit issues and pull requests.

## License

MIT License - feel free to use and modify as you wish.
