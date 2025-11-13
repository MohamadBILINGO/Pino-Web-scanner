#!/usr/bin/env bash
set -euo pipefail

# install_deps.sh
# Installer for PinoScan dependencies (Debian/Ubuntu, macOS (Homebrew), RedHat/CentOS, WSL, Chocolatey)
# Authored by Mohamad (generated)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ASK_INSTALL=true

required_debian=(dnsutils whois curl iputils-ping)
optional_debian=(nmap jq)

required_redhat=(bind-utils whois curl iputils)
optional_redhat=(nmap jq)

# macOS/Homebrew mapping
required_brew=(bind whois curl)
optional_brew=(nmap jq)

choco_pkgs=(curl nmap)

confirm() {
  read -r -p "$1 [y/N]: " response
  case "$response" in
    [yY][eE][sS]|[yY])
      true
      ;;
    *)
      false
      ;;
  esac
}

command_exists() { command -v "$1" &>/dev/null; }

echo -e "${YELLOW}PinoScan dependency installer${NC}\n"

# Detect WSL
is_wsl=false
if grep -qi microsoft /proc/version 2>/dev/null || [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
  is_wsl=true
fi

# Detect package manager
if command_exists apt; then
  pm=apt
elif command_exists dnf; then
  pm=dnf
elif command_exists yum; then
  pm=yum
elif command_exists brew; then
  pm=brew
elif command_exists choco; then
  pm=choco
else
  pm=unknown
fi

echo "Detected package manager: $pm"

if [[ "$pm" == "unknown" ]]; then
  echo -e "${RED}Could not detect a supported package manager.\nPlease install the following tools manually: dnsutils (dig), whois, curl, ping. For Windows use WSL or Chocolatey.${NC}"
  exit 1
fi

if [[ "$pm" == "apt" ]]; then
  echo -e "${GREEN}Preparing to install required packages on Debian/Ubuntu...${NC}"
  echo "Required: ${required_debian[*]}"
  echo "Optional: ${optional_debian[*]}"
  if confirm "Install required packages now?"; then
    sudo apt update
    sudo apt install -y "${required_debian[@]}"
  else
    echo "Skipping required packages. Exiting."
    exit 1
  fi
  if confirm "Install optional packages (nmap, jq)?"; then
    sudo apt install -y "${optional_debian[@]}"
  fi

elif [[ "$pm" == "dnf" || "$pm" == "yum" ]]; then
  echo -e "${GREEN}Preparing to install required packages on RHEL/CentOS/Fedora...${NC}"
  echo "Required: ${required_redhat[*]}"
  echo "Optional: ${optional_redhat[*]}"
  if confirm "Install required packages now?"; then
    sudo ${pm} install -y "${required_redhat[@]}"
  else
    echo "Skipping required packages. Exiting."
    exit 1
  fi
  if confirm "Install optional packages (nmap, jq)?"; then
    sudo ${pm} install -y "${optional_redhat[@]}"
  fi

elif [[ "$pm" == "brew" ]]; then
  echo -e "${GREEN}Preparing to install required packages with Homebrew...${NC}"
  echo "Required: ${required_brew[*]}"
  echo "Optional: ${optional_brew[*]}"
  if confirm "Install required packages now?"; then
    brew update
    brew install "${required_brew[@]}"
  else
    echo "Skipping required packages. Exiting."
    exit 1
  fi
  if confirm "Install optional packages (nmap, jq)?"; then
    brew install "${optional_brew[@]}"
  fi

elif [[ "$pm" == "choco" ]]; then
  echo -e "${GREEN}Chocolatey detected (Windows). Installing packages...${NC}"
  echo "Packages: ${choco_pkgs[*]}"
  if confirm "Install packages with Chocolatey now?"; then
    choco install -y "${choco_pkgs[@]}"
  else
    echo "Skipping installation. Exiting."
    exit 1
  fi
fi

# Post-install checks
echo -e "\n${YELLOW}Verifying tools are installed:${NC}"
for cmd in dig whois curl ping; do
  if command_exists "$cmd"; then
    echo -e "  ${GREEN}[OK]${NC} $cmd"
  else
    echo -e "  ${RED}[MISSING]${NC} $cmd"
  fi
done

if command_exists nmap; then
  echo -e "  ${GREEN}[OK]${NC} nmap"
else
  echo -e "  ${YELLOW}[OPTIONAL MISSING]${NC} nmap (useful for port/os detection)"
fi

if command_exists jq; then
  echo -e "  ${GREEN}[OK]${NC} jq"
else
  echo -e "  ${YELLOW}[OPTIONAL MISSING]${NC} jq"
fi

echo -e "\n${GREEN}Done. You can now run the PinoScan script. Example:\n  bash pinoscan.sh example.com${NC}"
