#!/usr/bin/env bash
#
# install-kali-tools.sh
#
# A Kali Linux-inspired pentest/security toolkit for Ubuntu.
# Does not add the Kali Linux repository to Ubuntu.
#

set -u

if [[ $EUID -eq 0 ]]; then
    echo "Do not run this script as root."
    echo "Run: ./install-kali-tools.sh"
    exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
    echo "sudo is missing."
    exit 1
fi

if [[ ! -f /etc/os-release ]]; then
    echo "The operating system could not be recognized."
    exit 1
fi

source /etc/os-release

if [[ "$ID" != "ubuntu" ]]; then
    echo "This script is intended for Ubuntu."
    echo "Identified: ${PRETTY_NAME:-unknown}"
    exit 1
fi

echo
echo "=============================================="
echo " Ubuntu Security / Pentest Tool Installer"
echo "=============================================="
echo
echo "OS: ${PRETTY_NAME}"
echo

read -rp "Should we continue with the installation?? [y/N] " answer
[[ "$answer" =~ ^[Yy]$ ]] || exit 0

echo
echo "[+] Updating package lists..."
sudo apt update

# ------------------------------------------------
# Network / Recon
# ------------------------------------------------

NETWORK_TOOLS=(
    nmap
    masscan
    netcat-openbsd
    socat
    tcpdump
    traceroute
    mtr-tiny
    iperf3
    dnsutils
    whois
    arp-scan
    net-tools
    ethtool
    iproute2
    curl
    wget
    jq
)

# ------------------------------------------------
# Web security
# ------------------------------------------------

WEB_TOOLS=(
    nikto
    gobuster
    ffuf
    sqlmap
    whatweb
    wpscan
)

# ------------------------------------------------
# Password / authentication
# ------------------------------------------------

PASSWORD_TOOLS=(
    john
    hashcat
    hydra
    medusa
    hashid
)

# ------------------------------------------------
# Packet analysis
# ------------------------------------------------

PACKET_TOOLS=(
    wireshark
    tshark
    ettercap-common
    bettercap
)

# ------------------------------------------------
# SMB / Windows / AD
# ------------------------------------------------

WINDOWS_TOOLS=(
    smbclient
    ldap-utils
    rpcclient
    enum4linux
    crackmapexec
)

# ------------------------------------------------
# Forensics
# ------------------------------------------------

FORENSICS_TOOLS=(
    binwalk
    foremost
    sleuthkit
    testdisk
    exiftool
)

# ------------------------------------------------
# Exploit / development
# ------------------------------------------------

DEV_TOOLS=(
    git
    gcc
    g++
    make
    cmake
    python3
    python3-pip
    python3-venv
    ruby
    perl
    golang
    gdb
    strace
    ltrace
)

# ------------------------------------------------
# SSH / remote administration
# ------------------------------------------------

REMOTE_TOOLS=(
    openssh-client
    sshpass
    rdesktop
    freerdp2-x11
)

# ------------------------------------------------
# General utilities
# ------------------------------------------------

UTILITY_TOOLS=(
    vim
    tmux
    screen
    tree
    unzip
    p7zip-full
    ripgrep
    htop
    ncdu
    rsync
)

ALL_TOOLS=(
    "${NETWORK_TOOLS[@]}"
    "${WEB_TOOLS[@]}"
    "${PASSWORD_TOOLS[@]}"
    "${PACKET_TOOLS[@]}"
    "${WINDOWS_TOOLS[@]}"
    "${FORENSICS_TOOLS[@]}"
    "${DEV_TOOLS[@]}"
    "${REMOTE_TOOLS[@]}"
    "${UTILITY_TOOLS[@]}"
)

echo
echo "[+] Checking packages..."
echo

AVAILABLE=()
MISSING=()

for pkg in "${ALL_TOOLS[@]}"; do
    if apt-cache show "$pkg" >/dev/null 2>&1; then
        AVAILABLE+=("$pkg")
    else
        MISSING+=("$pkg")
    fi
done

echo "[+] Installable packages: ${#AVAILABLE[@]}"
echo "[!] Missing packages:     ${#MISSING[@]}"
echo

# ------------------------------------------------
# Installation
# ------------------------------------------------

if [[ ${#AVAILABLE[@]} -gt 0 ]]; then
    echo "[+] Let's install the tools..."
    sudo apt install -y "${AVAILABLE[@]}"
fi

# ------------------------------------------------
# Wireshark permissions
# ------------------------------------------------

if dpkg -s wireshark >/dev/null 2>&1; then
    echo
    echo "[+] Adding a user to the wireshark group..."
    sudo usermod -aG wireshark "$USER"
fi

# ------------------------------------------------
# Python security tools
# ------------------------------------------------

echo
echo "[+] Let's check Python pip..."

if command -v pip3 >/dev/null 2>&1; then
    echo "[+] Python pip is available."
else
    echo "[!] pip3 not found."
fi

# ------------------------------------------------
# Results
# ------------------------------------------------

echo
echo "=============================================="
echo " Installation complete"
echo "=============================================="
echo

echo "Installed/Available Packages:"
echo

for pkg in "${AVAILABLE[@]}"; do
    if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | \
        grep -q "install ok installed"; then
        printf "  [OK]   %s\n" "$pkg"
    else
        printf "  [FAIL] %s\n" "$pkg"
    fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
    echo
    echo "No packages were found in this Ubuntu repository.:"
    echo

    for pkg in "${MISSING[@]}"; do
        printf "  [--]   %s\n" "$pkg"
    done
fi

echo
echo "=============================================="
echo " Seuraavat työkalut voidaan tarkistaa:"
echo "=============================================="
echo
echo "Nmap:       nmap --version"
echo "Masscan:    masscan --version"
echo "Gobuster:   gobuster version"
echo "FFUF:       ffuf -V"
echo "SQLMap:     sqlmap --version"
echo "Nikto:      nikto -Version"
echo "John:       john --version"
echo "Hashcat:    hashcat --version"
echo "Hydra:      hydra -h"
echo "Metasploit: msfconsole"
echo "Wireshark:  wireshark --version"
echo

echo "Note:"
echo "The Wireshark group change requires you to log out"
echo "and log back in before it takes effect."
echo

echo "The Metasploit Framework is not included in this APT list."
echo "It can be installed separately using the official Rapid7 installer."
echo
