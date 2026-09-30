#!/usr/bin/env bash
#
# nmap-update.sh
#
# Päivittää:
#   - Nmap
#   - NSE-scripts
#   - NSE script database
#   - vulners.nse
#
# Finally, test the CVE search.
#
# Supported:
#   - Ubuntu
#   - Debian
#   - Kali Linux
#
# Use:
#   sudo ./nmap-update.sh
#

set -euo pipefail

NMAP_SCRIPT_DIR="/usr/share/nmap/scripts"
VULNERS_URL="https://raw.githubusercontent.com/vulnersCom/nmap-vulners/master/vulners.nse"

log() {
    echo
    echo "==> $*"
}

error() {
    echo
    echo "[ERROR] $*" >&2
    exit 1
}

# ------------------------------------------------------------
# Root check
# ------------------------------------------------------------

if [[ $EUID -ne 0 ]]; then
    error "Run the script with root privileges: sudo $0"
fi

# ------------------------------------------------------------
# OS detection
# ------------------------------------------------------------

if [[ ! -f /etc/os-release ]]; then
    error "/etc/os-release was not found."
fi

source /etc/os-release

echo
echo "=============================================="
echo " Nmap / NSE / Vulners update"
echo "=============================================="
echo
echo "OS:      ${PRETTY_NAME:-unknown}"
echo "Version: ${VERSION_ID:-unknown}"
echo

case "${ID:-}" in
    ubuntu|debian|kali)
        ;;
    *)
        case "${ID_LIKE:-}" in
            *debian*)
                ;;
            *)
                error "This script is not intended for the operating system.: ${ID:-unknown}"
                ;;
        esac
        ;;
esac

# ------------------------------------------------------------
# Dependencies
# ------------------------------------------------------------

log "Checking dependencies"

export DEBIAN_FRONTEND=noninteractive

apt-get update

apt-get install -y \
    nmap \
    curl \
    ca-certificates \
    git

# ------------------------------------------------------------
# Nmap version
# ------------------------------------------------------------

log "Installed Nmap version"

nmap --version | head -n 3

# ------------------------------------------------------------
# Update Nmap package
# ------------------------------------------------------------

log "Update Nmap"

apt-get install --only-upgrade -y nmap

echo
nmap --version | head -n 3

# ------------------------------------------------------------
# Check NSE directory
# ------------------------------------------------------------

if [[ ! -d "$NMAP_SCRIPT_DIR" ]]; then
    error "Nmap NSE directory not found: $NMAP_SCRIPT_DIR"
fi

# ------------------------------------------------------------
# Update NSE script database
# ------------------------------------------------------------

log "Updating the NSE script database"

nmap --script-updatedb

# ------------------------------------------------------------
# Update vulners.nse
# ------------------------------------------------------------

log "Updating vulners.nse"

TMP_FILE="$(mktemp)"

if curl -fsSL "$VULNERS_URL" -o "$TMP_FILE"; then

    if grep -q "vulners.com" "$TMP_FILE"; then

        install -m 0644 "$TMP_FILE" \
            "$NMAP_SCRIPT_DIR/vulners.nse"

        echo "vulners.nse updated."

    else
        rm -f "$TMP_FILE"
        error "The downloaded vulners.nse does not appear to be the correct file."
    fi

else
    rm -f "$TMP_FILE"
    error "Failed to load vulners.nse."
fi

rm -f "$TMP_FILE"

# ------------------------------------------------------------
# Rebuild NSE database
# ------------------------------------------------------------

log "Rebuilding the NSE database"

nmap --script-updatedb

# ------------------------------------------------------------
# Verify scripts
# ------------------------------------------------------------

log "Checking NSE scripts"

if [[ -f "$NMAP_SCRIPT_DIR/vulners.nse" ]]; then
    echo "OK: vulners.nse löytyy."
else
    error "vulners.nse not found."
fi

echo
echo "Vulners script details:"
nmap --script-help vulners

# ------------------------------------------------------------
# Test CVE functionality
# ------------------------------------------------------------

log "Testing CVE search"

echo
echo "Test target: scanme.nmap.org"
echo "Using Nmap version detection + vulners NSE."
echo

if nmap -sV \
    --script vulners \
    --script-args mincvss=0 \
    -Pn \
    scanme.nmap.org
then

    echo
    echo "=============================================="
    echo " CVE TEST COMPLETED"
    echo "=============================================="
    echo
    echo "If the output showed CVE/VULNERABILITY information,"
    echo "vulners NSE works."
    echo

else

    echo
echo "[WARNING] CVE test failed."
echo "Check network connection and DNS."
    echo

fi

# ------------------------------------------------------------
# Final information
# ------------------------------------------------------------

echo
echo "=============================================="
echo " Update complete"
echo "=============================================="
echo
echo "Nmap:"
nmap --version | head -n 1

echo
echo "NSE scripts:"
find "$NMAP_SCRIPT_DIR" -maxdepth 1 -type f -name '*.nse' | wc -l

echo
echo "vulners.nse:"
ls -lh "$NMAP_SCRIPT_DIR/vulners.nse"

echo
echo "NSE database:"
ls -lh /usr/share/nmap/scripts/script.db 2>/dev/null || true

echo
echo "Ready."
echo
