#!/bin/bash

# [Task 97] دالة جلب وتحويل الـ Uptime
get_system_uptime() {
    if [ -f "/proc/uptime" ]; then
        local total_seconds
        total_seconds=$(awk '{print int($1)}' /proc/uptime)

        local days=$(( total_seconds / 86400 ))
        local hours=$(( (total_seconds % 86400) / 3600 ))
        local minutes=$(( (total_seconds % 3600) / 60 ))

        local uptime_str=""
        if [ "$days" -gt 0 ]; then
            uptime_str="${days}d "
        fi
        uptime_str="${uptime_str}${hours}h ${minutes}m"
        
        echo "$uptime_str"
    else
        echo "N/A"
    fi
}

# [Task 98] دالة جلب وتنسيق الـ Load Average
get_load_average() {
    if [ -f "/proc/loadavg" ]; then
        local load_1m load_5m load_15m
        read -r load_1m load_5m load_15m _ < /proc/loadavg
        echo "${load_1m}, ${load_5m}, ${load_15m}"
    else
        echo "N/A"
    fi
}

# ====================================================
# [Task 99 & 100] دالة جلب إحصائيات الشبكة (RX / TX)
# ====================================================
get_network_stats() {
    local dev_file="/proc/net/dev"
    if [ -f "$dev_file" ]; then
        # تحديد كارت الشبكة النشط (افتراضياً eth0 أو أول كارت حقيقي غير الـ lo)
        local interface
        interface=$(awk 'NR>2 {print $1}' "$dev_file" | cut -d':' -f1 | grep -v "lo" | head -n 1)

        if [ -z "$interface" ]; then
            echo "RX: 0 KB | TX: 0 KB"
            return
        fi

        # قراءة الـ Bytes المستقبلة والمرسلة للكارت المحدد
        local rx_bytes tx_bytes
        rx_bytes=$(awk -v iface="$interface" '$1 ~ iface {print $2}' "$dev_file")
        tx_bytes=$(awk -v iface="$interface" '$1 ~ iface {print $10}' "$dev_file")

        # تحويل القيم من Bytes إلى Kilobytes لتكون أكثر واقعية وسهلة القراءة
        local rx_kb=$(( rx_bytes / 1024 ))
        local tx_kb=$(( tx_bytes / 1024 ))

        echo "RX: ${rx_kb} KB | TX: ${tx_kb} KB (via $interface)"
    else
        echo "RX: N/A | TX: N/A"
    fi
}

# تشغيل فحص تجريبي للمقاييس المتقدمة مجتمعة
echo "-----------------------------------"
echo "🕒 Checking Advanced System Metrics..."
echo "   Current Uptime: $(get_system_uptime)"
echo "   Load Average  : $(get_load_average)"
echo "   Network Traffic: $(get_network_stats)"
echo "-----------------------------------"