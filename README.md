# Universal Developer Environment Setup

Automatically set up a complete development environment on any Unix-based system (Linux, macOS, BSD) with a single command.

## Quick Install

```bash
# Using curl (recommended)
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/yourusername/dev-setup/main/dev_setup.sh)"

# Using wget (alternative)
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/yourusername/dev-setup/main/dev_setup.sh)"
```

⚠️ **Security First**: Always verify the script before running:
```bash
# View the script content before executing
curl -fsSL https://raw.githubusercontent.com/yourusername/dev-setup/main/dev_setup.sh | less
```

## Features

- 🔍 Automatic OS detection and package manager setup
- 🛠️ Development tools installation
    - Git
    - Python 3 with pip
    - Node.js (with option for nvm or system package)
    - Docker
    - Visual Studio Code
    - JetBrains Toolbox
- ⚡ Shell enhancements
    - Zsh with Oh My Zsh
    - Terminal utilities (tmux, vim, etc.)
- 🔧 Development environment configuration
    - Git global configuration
    - Python virtual environment setup
    - Node.js global packages
- 🐳 Docker setup with user permissions
- ⌨️ Code editor installation and setup

## Supported Operating Systems

- Ubuntu/Debian based systems (including Pop!_OS, Linux Mint)
- Fedora/RHEL based systems
- Arch Linux/Manjaro
- openSUSE
- BSD systems (FreeBSD, OpenBSD, NetBSD)
- macOS

## What Gets Installed

### Core Development Tools
- Git
- Python 3 with pip
- Node.js (choice of nvm or system package)
- Docker
- Visual Studio Code
- JetBrains Toolbox

### Terminal Utilities
- Zsh & Oh My Zsh
- tmux
- vim/neovim
- curl/wget
- htop

### Python Packages
- pytest
- black
- flake8
- pylint
- mypy
- requests
- python-dotenv

### Node.js Global Packages
- typescript
- eslint
- prettier
- nodemon
- npm-check-updates

## Customization

You can customize the installation by setting environment variables before running the script:

```bash
# Example: Skip Node.js installation
export SKIP_NODE=true
# Example: Skip Docker installation
export SKIP_DOCKER=true
# Example: Skip VS Code installation
export SKIP_VSCODE=true

# Then run the installation
sudo -E bash -c "$(curl -fsSL https://raw.githubusercontent.com/yourusername/dev-setup/main/dev_setup.sh)"
```

## Post Installation

After installation:
1. Log out and log back in for group changes to take effect
2. Start JetBrains Toolbox to install preferred IDEs
3. Configure Git with your credentials:
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## Security Considerations

This script:
- Uses HTTPS for all downloads
- Verifies package signatures where possible
- Doesn't store or transmit any personal information
- Runs with sudo only where necessary
- Is open source and auditable

## Troubleshooting

If you encounter issues:

1. Check system requirements:
```bash
# Check OS version
cat /etc/os-release
# Check available disk space
df -h
```

2. Review logs:
```bash
# The script creates a log file at:
cat ~/dev_setup_log.txt
```

3. Common issues:
- Permission denied: Make sure to run with sudo
- Package manager errors: Check internet connection
- Docker issues: May need system restart

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT License - feel free to use, modify, and distribute as needed.

## Support

If you encounter any issues or have questions:
1. Check the [Issues](https://github.com/yourusername/dev-setup/issues) page
2. Create a new issue if needed
3. Join our [Discord community](your-discord-link)

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=yourusername/dev-setup&type=Date)](https://star-history.com/#yourusername/dev-setup&Date)

