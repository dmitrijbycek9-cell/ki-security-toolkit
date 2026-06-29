#!/bin/bash
# KI Security Toolkit — Auto-Installer
# Ein Befehl. Alles wird gemacht.

set -e

REPO="https://raw.githubusercontent.com/dmitrijbycek9-cell/ki-security-toolkit/main"
INSTALL_DIR="$HOME/ki-toolkit"

echo "==============================================="
echo "  KI Security Toolkit — Auto-Installer"
echo "==============================================="
echo ""

# 1. Python check
if ! command -v python3 &>/dev/null; then
    echo "[+] Installing Python..."
    if command -v pkg &>/dev/null; then
        pkg install python python-pip -y
    elif command -v apt &>/dev/null; then
        apt install python3 python3-pip -y
    else
        echo "[!] Install python3 manually"
        exit 1
    fi
fi
echo "[OK] Python ready"

# 2. anthropic SDK
echo "[+] Installing anthropic SDK..."
pip3 install anthropic --quiet 2>/dev/null || pip install anthropic --quiet
echo "[OK] SDK ready"

# 3. Download tools
echo "[+] Downloading tools..."
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

for file in best_of_n.py crescendo.py prompt_scanner.py; do
    if command -v curl &>/dev/null; then
        curl -fsSL -o "$file" "$REPO/$file"
    elif command -v wget &>/dev/null; then
        wget -qO "$file" "$REPO/$file"
    else
        echo "[!] Need curl or wget"
        exit 1
    fi
    echo "  Downloaded: $file"
done

chmod +x *.py

# 4. API Key
echo ""
echo "==============================================="
echo "  API Key Setup"
echo "==============================================="
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo -n "Enter your Anthropic API Key: "
    read ANTHROPIC_API_KEY
fi

if [ -n "$ANTHROPIC_API_KEY" ]; then
    echo "export ANTHROPIC_API_KEY=\"$ANTHROPIC_API_KEY\"" >> ~/.bashrc
    export ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY"
    echo "[OK] API Key saved"
fi

# 5. Aliases
echo "" >> ~/.bashrc
echo "# KI Security Toolkit" >> ~/.bashrc
echo "alias ki-scan='cd $INSTALL_DIR && python3 prompt_scanner.py --target'" >> ~/.bashrc
echo "alias ki-bestn='cd $INSTALL_DIR && python3 best_of_n.py --prompt'" >> ~/.bashrc
echo "alias ki-crescendo='cd $INSTALL_DIR && python3 crescendo.py --target'" >> ~/.bashrc
source ~/.bashrc 2>/dev/null || true

# 6. Done
echo ""
echo "==============================================="
echo "  DONE!"
echo "==============================================="
echo ""
echo "Tools installed to: $INSTALL_DIR"
echo ""
echo "Quick aliases:"
echo "  ki-scan 'target'        — Prompt Scanner"
echo "  ki-bestn 'target' -n 100 — Best-of-N"
echo "  ki-crescendo --target 'X' --topic 'Y'"
echo ""
echo "Or cd $INSTALL_DIR and:"
echo "  python3 best_of_n.py --help"
echo "  python3 crescendo.py --help"
echo "  python3 prompt_scanner.py --help"
echo ""
echo "Get API key: https://console.anthropic.com"
echo ""
