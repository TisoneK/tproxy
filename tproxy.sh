#!/bin/bash
# tproxy - Terminal Proxy Manager (Terminal + APT + System)
# Supports both interactive menu & non-interactive CLI

PROXY_FILE="/etc/apt/apt.conf.d/proxy.conf"
ENV_FILE="/etc/environment"
CONF_FILE="$HOME/.proxy_manager.conf"

# ---------------- Functions ---------------- #

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
}

save_last_proxy() {
    echo "$1" > "$CONF_FILE"
}

load_last_proxy() {
    [[ -f "$CONF_FILE" ]] && cat "$CONF_FILE"
}

toggle_proxy() {
    LAST_PROXY=$(load_last_proxy)
    if [[ -z "$LAST_PROXY" ]]; then
        echo "[!] No saved proxy found. Please set one first."
        return
    fi

    if [[ -z "$http_proxy" && ! -f $PROXY_FILE && -z $(grep -E "http_proxy|https_proxy" $ENV_FILE) ]]; then
        echo "[*] No proxy detected → Enabling $LAST_PROXY"
        set_proxy_terminal "$LAST_PROXY"
        set_proxy_apt "$LAST_PROXY"
        set_proxy_system "$LAST_PROXY"
    else
        echo "[*] Proxy detected → Disabling"
        disable_proxy_terminal
        disable_proxy_apt
        disable_proxy_system
    fi
}

# ---------------- Menus ---------------- #

submenu_set() {
    clear
    echo "=== Set Proxy ==="
    echo "1) Terminal"
    echo "2) APT"
    echo "3) System"
    echo "4) All"
    echo "5) Back"
    read -p "Choose [1-5]: " opt
    case $opt in
        1) read -p "Enter proxy URL: " PROXY; set_proxy_terminal "$PROXY"; save_last_proxy "$PROXY" ;;
        2) read -p "Enter proxy URL: " PROXY; set_proxy_apt "$PROXY"; save_last_proxy "$PROXY" ;;
        3) read -p "Enter proxy URL: " PROXY; set_proxy_system "$PROXY"; save_last_proxy "$PROXY" ;;
        4) read -p "Enter proxy URL: " PROXY; set_proxy_terminal "$PROXY"; set_proxy_apt "$PROXY"; set_proxy_system "$PROXY"; save_last_proxy "$PROXY" ;;
        5) return ;;
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
    echo "4) All"
    echo "5) Back"
    read -p "Choose [1-5]: " opt
    case $opt in
        1) disable_proxy_terminal ;;
        2) disable_proxy_apt ;;
        3) disable_proxy_system ;;
        4) disable_proxy_terminal; disable_proxy_apt; disable_proxy_system ;;
        5) return ;;
        *) echo "[!] Invalid choice" ;;
    esac
    read -p "Press Enter to continue..."
}

main_menu() {
    while true; do
        clear
        echo "===== Proxy Manager (tproxy) ====="
        echo "1) Set Proxy"
        echo "2) Disable Proxy"
        echo "3) Toggle Proxy"
        echo "4) Show Current Proxy"
        echo "5) Exit"
        echo "=================================="
        read -p "Choose [1-5]: " choice

        case $choice in
            1) submenu_set ;;
            2) submenu_disable ;;
            3) toggle_proxy; read -p "Press Enter to continue..." ;;
            4) show_current; read -p "Press Enter to continue..." ;;
            5) clear; echo "Goodbye!"; exit 0 ;;
            *) echo "[!] Invalid choice"; sleep 1 ;;
        esac
    done
}

# ---------------- CLI Parser ---------------- #

if [[ $# -gt 0 ]]; then
    case $1 in
        set)
            [[ $# -lt 3 ]] && { echo "Usage: tproxy set {terminal|apt|system|all} URL"; exit 1; }
            save_last_proxy "$3"
            case $2 in
                terminal) set_proxy_terminal "$3" ;;
                apt) set_proxy_apt "$3" ;;
                system) set_proxy_system "$3" ;;
                all) set_proxy_terminal "$3"; set_proxy_apt "$3"; set_proxy_system "$3" ;;
                *) echo "[!] Invalid target. Use terminal|apt|system|all" ;;
            esac
            ;;
        disable)
            [[ $# -lt 2 ]] && { echo "Usage: tproxy disable {terminal|apt|system|all}"; exit 1; }
            case $2 in
                terminal) disable_proxy_terminal ;;
                apt) disable_proxy_apt ;;
                system) disable_proxy_system ;;
                all) disable_proxy_terminal; disable_proxy_apt; disable_proxy_system ;;
                *) echo "[!] Invalid target. Use terminal|apt|system|all" ;;
            esac
            ;;
        toggle)
            toggle_proxy
            ;;
        show)
            show_current
            ;;
        *)
            echo "Usage:"
            echo "  tproxy set {terminal|apt|system|all} URL"
            echo "  tproxy disable {terminal|apt|system|all}"
            echo "  tproxy toggle"
            echo "  tproxy show"
            ;;
    esac
else
    main_menu
fi

