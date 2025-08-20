#!/bin/bash
# TProxy - Terminal, APT, System & Git Proxy Manager

PROXY_FILE="/etc/apt/apt.conf.d/proxy.conf"
ENV_FILE="/etc/environment"
CONFIG_FILE="$HOME/.tproxy.conf"
SCRIPT_PATH="/usr/local/bin/tproxy"

# Save proxy to config
save_proxy() {
    echo "$1" > "$CONFIG_FILE"
}

# Load last proxy from config
load_proxy() {
    if [[ -f $CONFIG_FILE ]]; then
        cat "$CONFIG_FILE"
    else
        echo ""
    fi
}

# ------------------------
# Proxy Setters
# ------------------------
set_proxy_terminal() {
    export http_proxy=$1
    export https_proxy=$1
    echo "[+] Proxy set for this terminal session."
}

set_proxy_apt() {
    echo "Acquire::http::Proxy \"$1\";" | sudo tee $PROXY_FILE > /dev/null
    echo "Acquire::https::Proxy \"$1\";" | sudo tee -a $PROXY_FILE > /dev/null
    echo "[+] Proxy set for APT."
}

set_proxy_system() {
    sudo sed -i '/http_proxy\|https_proxy/d' $ENV_FILE
    echo "http_proxy=\"$1\"" | sudo tee -a $ENV_FILE > /dev/null
    echo "https_proxy=\"$1\"" | sudo tee -a $ENV_FILE > /dev/null
    echo "[+] Proxy set system-wide (requires logout/login)."
}

set_proxy_git() {
    git config --global http.proxy "$1"
    git config --global https.proxy "$1"
    echo "[+] Proxy set for Git."
}

# ------------------------
# Proxy Disablers
# ------------------------
disable_proxy_terminal() {
    unset http_proxy https_proxy
    echo "[+] Proxy disabled for terminal session."
}

disable_proxy_apt() {
    sudo rm -f $PROXY_FILE
    echo "[+] Proxy disabled for APT."
}

disable_proxy_system() {
    sudo sed -i '/http_proxy\|https_proxy/d' $ENV_FILE
    echo "[+] Proxy disabled system-wide (requires logout/login)."
}

disable_proxy_git() {
    git config --global --unset http.proxy
    git config --global --unset https.proxy
    echo "[+] Proxy disabled for Git."
}

# ------------------------
# Show Current
# ------------------------
show_current() {
    clear
    echo "=== Current Proxy Status ==="
    echo "Terminal proxy: ${http_proxy:-Not set}"
    echo ""
    if [[ -f $PROXY_FILE ]]; then
        echo "APT proxy:"
        cat $PROXY_FILE
    else
        echo "APT proxy: Not set"
    fi
    echo ""
    echo "System proxy (from $ENV_FILE):"
    grep -E "http_proxy|https_proxy" $ENV_FILE || echo "Not set"
    echo ""
    echo "Git proxy:"
    git config --get http.proxy || echo "Not set"
    git config --get https.proxy || echo "Not set"
}

# ------------------------
# Toggle Proxy
# ------------------------
toggle_proxy() {
    local CURRENT=$(git config --get http.proxy)
    if [[ -n "$CURRENT" ]]; then
        echo "[*] Proxy currently enabled. Disabling..."
        disable_proxy_terminal
        disable_proxy_apt
        disable_proxy_system
        disable_proxy_git
    else
        local LAST_PROXY=$(load_proxy)
        if [[ -z "$LAST_PROXY" ]]; then
            read -p "Enter proxy URL: " LAST_PROXY
            save_proxy "$LAST_PROXY"
        fi
        echo "[*] Enabling proxy: $LAST_PROXY"
        set_proxy_terminal "$LAST_PROXY"
        set_proxy_apt "$LAST_PROXY"
        set_proxy_system "$LAST_PROXY"
        set_proxy_git "$LAST_PROXY"
    fi
    read -p "Press Enter to continue..."
}

# ------------------------
# Uninstall Functionality
# ------------------------
uninstall_tproxy() {
    echo "[*] Uninstalling TProxy..."

    # Disable all proxies before removal
    disable_proxy_terminal
    disable_proxy_apt
    disable_proxy_system
    disable_proxy_git

    # Remove config file
    rm -f "$CONFIG_FILE"

    # Remove installed script (if running from /usr/local/bin)
    if [[ -f "$SCRIPT_PATH" ]]; then
        sudo rm -f "$SCRIPT_PATH"
        echo "[+] Removed $SCRIPT_PATH"
    fi

    echo "[+] TProxy has been fully uninstalled."
    exit 0
}

# ------------------------
# Submenus
# ------------------------
submenu_set() {
    clear
    echo "=== Set Proxy ==="
    echo "1) Terminal"
    echo "2) APT"
    echo "3) System"
    echo "4) Git"
    echo "5) All"
    echo "6) Back"
    read -p "Choose [1-6]: " opt
    case $opt in
        1) read -p "Enter proxy URL: " PROXY; set_proxy_terminal "$PROXY"; save_proxy "$PROXY" ;;
        2) read -p "Enter proxy URL: " PROXY; set_proxy_apt "$PROXY"; save_proxy "$PROXY" ;;
        3) read -p "Enter proxy URL: " PROXY; set_proxy_system "$PROXY"; save_proxy "$PROXY" ;;
        4) read -p "Enter proxy URL: " PROXY; set_proxy_git "$PROXY"; save_proxy "$PROXY" ;;
        5) read -p "Enter proxy URL: " PROXY; set_proxy_terminal "$PROXY"; set_proxy_apt "$PROXY"; set_proxy_system "$PROXY"; set_proxy_git "$PROXY"; save_proxy "$PROXY" ;;
        6) return ;;
        *) echo "[!] Invalid choice" ;;
    esac
    read -p "Press Enter to continue..."
}

submenu_disable() {
    clear
    echo "=== Disable Proxy ==="
    echo "1) Terminal"
    echo "2) APT"
    echo "3) System"
    echo "4) Git"
    echo "5) All"
    echo "6) Back"
    read -p "Choose [1-6]: " opt
    case $opt in
        1) disable_proxy_terminal ;;
        2) disable_proxy_apt ;;
        3) disable_proxy_system ;;
        4) disable_proxy_git ;;
        5) disable_proxy_terminal; disable_proxy_apt; disable_proxy_system; disable_proxy_git ;;
        6) return ;;
        *) echo "[!] Invalid choice" ;;
    esac
    read -p "Press Enter to continue..."
}

# ------------------------
# Main Menu / CLI
# ------------------------
if [[ "$1" == "uninstall" ]]; then
    uninstall_tproxy
fi

while true; do
    clear
    echo "===== TProxy Manager ====="
    echo "1) Set Proxy"
    echo "2) Disable Proxy"
    echo "3) Show Current Proxy"
    echo "4) Toggle Proxy"
    echo "5) Exit"
    echo "6) Uninstall TProxy"
    echo "=========================="
    read -p "Choose [1-6]: " choice

    case $choice in
        1) submenu_set ;;
        2) submenu_disable ;;
        3) show_current; read -p "Press Enter to continue..." ;;
        4) toggle_proxy ;;
        5) clear; echo "Goodbye!"; exit 0 ;;
        6) uninstall_tproxy ;;
        *) echo "[!] Invalid choice"; sleep 1 ;;
    esac
done

