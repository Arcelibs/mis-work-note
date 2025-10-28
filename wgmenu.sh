#!/bin/bash
# WireGuard Client Interactive Control Menu
# Author: arcelibs / ChatGPT
# Version: 1.1

WG_CONF="/etc/wireguard/wg0.conf"   # ⚙️ 你的 WireGuard 設定檔
WG_IFACE="wg0"                      # ⚙️ WireGuard 介面名稱 (通常是 wg0)

# 🟦 檢查 WireGuard 是否安裝
if ! command -v wg-quick &>/dev/null; then
    echo "❌ WireGuard 未安裝。請先執行：sudo apt install wireguard -y"
    exit 1
fi

show_ip_info() {
    echo "🌏 目前出口資訊："
    curl -s https://ipinfo.io | grep -E '"ip"|"country"|"org"'
}

start_vpn() {
    echo "🚀 啟動 WireGuard ($WG_IFACE)..."
    sudo wg-quick up "$WG_CONF" && sleep 2
    show_ip_info
}

stop_vpn() {
    echo "🛑 關閉 WireGuard ($WG_IFACE)..."
    sudo wg-quick down "$WG_CONF"
    show_ip_info
}

restart_vpn() {
    echo "♻️ 重新啟動 WireGuard ($WG_IFACE)..."
    sudo wg-quick down "$WG_CONF" 2>/dev/null
    sudo wg-quick up "$WG_CONF" && sleep 2
    show_ip_info
}

status_vpn() {
    echo "📡 WireGuard 狀態："
    if ip a | grep -q "$WG_IFACE"; then
        echo "✅ $WG_IFACE 已啟動"
        sudo wg show
    else
        echo "❌ $WG_IFACE 尚未啟動"
    fi
    show_ip_info
}

while true; do
    clear
    echo "============================"
    echo " 🔧 WireGuard 控制選單"
    echo "============================"
    echo "1️⃣  啟動 VPN"
    echo "2️⃣  關閉 VPN"
    echo "3️⃣  重新啟動 VPN"
    echo "4️⃣  查看狀態"
    echo "5️⃣  顯示出口 IP"
    echo "0️⃣  離開"
    echo "============================"
    read -p "請選擇操作： " choice

    case "$choice" in
        1) start_vpn ;;
        2) stop_vpn ;;
        3) restart_vpn ;;
        4) status_vpn ;;
        5) show_ip_info ;;
        0) echo "👋 再見！"; exit 0 ;;
        *) echo "❌ 無效的選項，請重新輸入。" ;;
    esac

    echo ""
    read -p "按 Enter 鍵返回選單..." temp
done
