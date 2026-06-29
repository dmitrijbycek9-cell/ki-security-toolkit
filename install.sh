#!/bin/bash
# KI Security Toolkit — Auto-Installer
# ZERO Dependencies — nur Python + urllib (Standard-Library)

set -e

REPO="https://raw.githubusercontent.com/dmitrijbycek9-cell/ki-security-toolkit/main"
INSTALL_DIR="$HOME/ki-toolkit"

echo "==============================================="
echo "  KI Security Toolkit — Auto-Installer"
echo "  ZERO Dependencies — nur Python stdlib"
echo "==============================================="
echo ""

# 1. Python check
if ! command -v python3 &>/dev/null; then
    echo "[+] Installing Python..."
    if command -v pkg &>/dev/null; then
        pkg install python -y
    elif command -v apt &>/dev/null; then
        apt install python3 -y
    elif command -v pacman &>/dev/null; then
        pacman -Sy python --noconfirm
    else
        echo "[!] Install python3 manually"
        exit 1
    fi
fi
echo "[OK] Python ready"

# 2. Download tools (KEIN pip install mehr nötig!)
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

# 3. API Key
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo ""
    echo -n "Enter your Anthropic API Key (or press Enter to skip): "
    read ANTHROPIC_API_KEY
    echo ""
fi

if [ -n "$ANTHROPIC_API_KEY" ]; then
    echo "export ANTHROPIC_API_KEY=\"$ANTHROPIC_API_KEY\"" >> ~/.bashrc
    export ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY"
    echo "[OK] API Key saved"
fi

# 4. Aliases
echo "" >> ~/.bashrc
echo "# KI Security Toolkit" >> ~/.bashrc
echo "alias ki-scan='cd $INSTALL_DIR && python3 prompt_scanner.py --target'" >> ~/.bashrc
echo "alias ki-bestn='cd $INSTALL_DIR && python3 best_of_n.py --prompt'" >> ~/.bashrc
echo "alias ki-crescendo='cd $INSTALL_DIR && python3 crescendo.py --target'" >> ~/.bashrc
echo "alias ki-dir='cd $INSTALL_DIR && ls -la'" >> ~/.bashrc
source ~/.bashrc 2>/dev/null || true

# 5. Done
echo ""
echo "==============================================="
echo "  ✅ DONE!"
echo "==============================================="
echo ""
echo "Tools: $INSTALL_DIR"
echo ""
echo "Aliases:"
echo "  ki-scan 'target'         — Prompt Scanner"
echo "  ki-bestn 'target' -n 100 — Best-of-N"
echo "  ki-crescendo --target 'X' --topic 'Y'"
echo "  ki-dir                   — Show files"
echo ""
echo "No dependencies needed! Just Python + API Key."
echo "Get key: https://console.anthropic.com"
echo ""
