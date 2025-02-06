#!/bin/bash
set -e

# Enhanced error handling
trap 'echo "Error occurred at line $LINENO. Exit code: $?" >&2' ERR

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Improved logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Check if script is run with sudo/root privileges
if [ "$(id -u)" -ne 0 ]; then 
    log_error "Please run as root or with sudo privileges"
fi

# Enhanced OS detection
detect_os() {
    if [ -f /etc/os-release ]; then
        # freedesktop.org and systemd
        . /etc/os-release
        OS=$NAME
        if [[ "$OS" == "Pop!_OS" ]]; then
            OS="Pop_OS"
        fi
        VER=$VERSION_ID
    elif [ -f /usr/local/etc/os-release ]; then
        # BSD systems
        . /usr/local/etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif command -v uname > /dev/null; then
        OS=$(uname -s)
        VER=$(uname -r)
        if [ "$OS" = "Darwin" ]; then
            OS="macOS"
            VER=$(sw_vers -productVersion)
        elif [ "$OS" = "FreeBSD" ] || [ "$OS" = "OpenBSD" ] || [ "$OS" = "NetBSD" ]; then
            # Keep BSD name as is
            :
        fi
    else
        log_error "Unable to detect operating system"
        exit 1
    fi
}

# Set package manager and commands based on OS
# Detect package manager and set commands
setup_package_manager() {
    case $(echo "$OS" | tr '[:upper:]' '[:lower:]') in
        *ubuntu*|*debian*|*mint*|*pop*|*kali*)
            PKG_MANAGER="apt-get"
            PKG_UPDATE="$PKG_MANAGER update && $PKG_MANAGER upgrade -y"
            PKG_INSTALL="$PKG_MANAGER install -y"
            ;;
        *fedora*)
            PKG_MANAGER="dnf"
            PKG_UPDATE="$PKG_MANAGER check-update; $PKG_MANAGER upgrade -y"
            PKG_INSTALL="$PKG_MANAGER install -y"
            ;;
        *centos*|*redhat*)
            PKG_MANAGER="yum"
            PKG_UPDATE="$PKG_MANAGER check-update; $PKG_MANAGER upgrade -y"
            PKG_INSTALL="$PKG_MANAGER install -y"
            ;;
        *suse*)
            PKG_MANAGER="zypper"
            PKG_UPDATE="$PKG_MANAGER refresh && $PKG_MANAGER update -y"
            PKG_INSTALL="$PKG_MANAGER install -y"
            ;;
        *arch*|*manjaro*)
            PKG_MANAGER="pacman"
            PKG_UPDATE="$PKG_MANAGER -Syu"
            PKG_INSTALL="$PKG_MANAGER -S --noconfirm"
            ;;
        *freebsd*|*openbsd*|*netbsd*)
            PKG_MANAGER="pkg"
            PKG_UPDATE="$PKG_MANAGER update && $PKG_MANAGER upgrade -y"
            PKG_INSTALL="$PKG_MANAGER install -y"
            ;;
        *macos*)
            if ! command -v brew >/dev/null 2>&1; then
                log_info "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            PKG_MANAGER="brew"
            PKG_UPDATE="$PKG_MANAGER update && $PKG_MANAGER upgrade"
            PKG_INSTALL="$PKG_MANAGER install"
            ;;
        *)
            log_error "Unsupported operating system: $OS"
            exit 1
            ;;
    esac
}
        ;;
    *)
        log_error "Unsupported operating system: $OS"
        ;;
esac

# Function to install packages
install_package() {
    log_info "Installing $1..."
    $PKG_INSTALL "$1" >/dev/null 2>&1 || log_warn "Failed to install $1"
}

# Update system packages
log_info "Updating system packages..."
$PKG_UPDATE || log_warn "Failed to update package list"
$PKG_UPGRADE || log_warn "Failed to upgrade packages"

# Install development essentials based on OS
log_info "Installing development essentials..."

# Define OS-specific package names
if [ "$OS" = "macOS" ]; then
    packages=(
        git
        python3
        node
        docker
        wget
        htop
        zsh
        tmux
        vim
        neovim
        visual-studio-code
    )
else
    packages=(
        git
        python3
        python3-pip
        python3-venv
        curl
        wget
        htop
        zsh
        tmux
        vim
        neovim
    )
fi

# Install packages
for package in "${packages[@]}"; do
    install_package "$package"
done

# Install JetBrains Toolbox and WebStorm
log_info "Installing JetBrains Toolbox..."
if [ "$OS" = "macOS" ]; then
    brew install --cask jetbrains-toolbox
    brew install --cask webstorm
else
    # Create temporary directory for downloads
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"

    # Download and install JetBrains Toolbox
    TOOLBOX_URL="https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.24.12080.tar.gz"
    wget -O jetbrains-toolbox.tar.gz $TOOLBOX_URL
    tar -xzf jetbrains-toolbox.tar.gz
    TOOLBOX_DIR=$(find . -maxdepth 1 -type d -name "jetbrains-toolbox-*")
    mv "$TOOLBOX_DIR/jetbrains-toolbox" /usr/local/bin/
    chmod +x /usr/local/bin/jetbrains-toolbox

    # Cleanup
    cd - > /dev/null
    rm -rf "$TEMP_DIR"

    log_info "JetBrains Toolbox installed. Please run 'jetbrains-toolbox' to install WebStorm."
fi

# Install additional tools based on OS
# Docker installation with universal support
install_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        log_info "Installing Docker..."
        case $(echo "$OS" | tr '[:upper:]' '[:lower:]') in
            *ubuntu*|*debian*|*mint*|*pop*)
                curl -fsSL https://get.docker.com | sh
                ;;
            *fedora*)
                $PKG_INSTALL dnf-plugins-core
                dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
                $PKG_INSTALL docker-ce docker-ce-cli containerd.io
                ;;
            *centos*|*redhat*)
                $PKG_INSTALL yum-utils
                yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
                $PKG_INSTALL docker-ce docker-ce-cli containerd.io
                ;;
            *suse*)
                $PKG_INSTALL docker
                ;;
            *arch*|*manjaro*)
                $PKG_INSTALL docker
                ;;
            *freebsd*)
                $PKG_INSTALL docker docker-compose
                ;;
            *macos*)
                $PKG_INSTALL docker docker-compose
                ;;
            *)
                log_error "Docker installation not supported for $OS"
                return 1
                ;;
        esac

        # Start Docker service
        if has_systemd; then
            systemctl enable docker
            systemctl start docker
        else
            manage_service docker start
        fi

        # Add user to docker group if not root
        if [ -n "$SUDO_USER" ]; then
            usermod -aG docker "$SUDO_USER"
        fi
    fi
}

    # Install VS Code if not on macOS
    if ! command -v code >/dev/null 2>&1; then
        case $(echo "$OS" | tr '[:upper:]' '[:lower:]') in
            *ubuntu*|*debian*|*mint*|*pop_os*)
                wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
                install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
                echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list
                $PKG_UPDATE
                $PKG_INSTALL code
                rm packages.microsoft.gpg
                ;;
            *fedora*|*redhat*|*centos*)
                rpm --import https://packages.microsoft.com/keys/microsoft.asc
                echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo
                $PKG_UPDATE
                $PKG_INSTALL code
                ;;
            *arch*|*manjaro*)
                $PKG_INSTALL visual-studio-code-bin
                ;;
        esac
    fi
fi

# Node.js installation
log_info "Setting up Node.js..."

# Check if Node.js is already installed
if command -v node >/dev/null 2>&1; then
    current_version=$(node -v)
    log_info "Node.js ${current_version} is already installed"
    read -p "Do you want to reinstall/switch installation method? [y/N]: " should_reinstall
    if [[ ! $should_reinstall =~ ^[Yy]$ ]]; then
        log_info "Skipping Node.js installation"
        # Install global packages if node exists
        log_info "Installing global npm packages..."
        npm_packages=(
            "typescript"
            "eslint"
            "prettier"
            "nodemon"
            "npm-check-updates"
        )
        for package in "${npm_packages[@]}"; do
            npm install -g "$package"
        done
        goto git_config
    fi
fi

read -p "Do you want to install Node.js using nvm (1) or system package manager (2)? [1/2]: " node_install_choice

case $node_install_choice in
    2)
        log_info "Installing Node.js using system package manager..."
        case $(echo "$OS" | tr '[:upper:]' '[:lower:]') in
            *ubuntu*|*debian*|*mint*|*pop_os*)
                curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
                $PKG_INSTALL nodejs
                ;;
            *fedora*|*redhat*|*centos*)
                curl -fsSL https://rpm.nodesource.com/setup_lts.x | bash -
                $PKG_INSTALL nodejs
                ;;
            *arch*|*manjaro*)
                $PKG_INSTALL nodejs npm
                ;;
            *macos*)
                $PKG_INSTALL node
                ;;
        esac
        ;;
    *)
        log_info "Installing Node.js using nvm..."
        if [ ! -d "$HOME/.nvm" ]; then
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            nvm install --lts
        fi
        ;;
esac

# Install global npm packages
log_info "Installing global npm packages..."
npm_packages=(
    "typescript"
    "eslint"
    "prettier"
    "nodemon"
    "npm-check-updates"
)

for package in "${npm_packages[@]}"; do
    npm install -g "$package"
done

git_config:
# Setup Git configuration
log_info "Setting up Git configuration..."
read -p "Enter your Git username: " git_username
read -p "Enter your Git email: " git_email
git config --global user.name "$git_username"
git config --global user.email "$git_email"
git config --global init.defaultBranch main
git config --global core.editor "vim"

# Create requirements.txt for Python packages
log_info "Creating Python requirements.txt..."
cat > requirements.txt << EOF
pytest
black
flake8
pylint
mypy
requests
python-dotenv
EOF

# Install Python packages
log_info "Installing Python packages..."
python3 -m pip install --user -r requirements.txt

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log_info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    # Fix permissions
    if [ -n "$SUDO_USER" ]; then
        chown -R $SUDO_USER:$SUDO_USER "$HOME/.oh-my-zsh"
    fi
fi

log_info "Development environment setup completed successfully!"
log_info "Please log out and log back in for all changes to take effect."
if [ "$OS" != "macOS" ]; then
    log_info "To install WebStorm, run 'jetbrains-toolbox' and install it through the JetBrains Toolbox App."
fi


