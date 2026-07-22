#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# استدعاء ملف الـ Logger
if [ -f "$SCRIPT_DIR/../utils/logger.sh" ]; then
    # shellcheck disable=SC1091
    source "$SCRIPT_DIR/../utils/logger.sh"
else
    log_info() { echo "[INFO] $*"; }
fi

# فحص الـ CPU
analyze_cpu() {
    local cpu_val
    cpu_val=$1
    if [ -z "$cpu_val" ]; then echo "UNKNOWN"; return; fi
    if [ "$cpu_val" -gt 90 ]; then echo "CRITICAL"; elif [ "$cpu_val" -gt 70 ]; then echo "WARNING"; else echo "OK"; fi
}

# فحص الـ RAM
analyze_ram() {
    local ram_val
    ram_val=$1
    if [ -z "$ram_val" ]; then echo "UNKNOWN"; return; fi
    if [ "$ram_val" -gt 90 ]; then echo "CRITICAL"; elif [ "$ram_val" -gt 80 ]; then echo "WARNING"; else echo "OK"; fi
}

# فحص الـ Disk
analyze_disk() {
    local disk_val
    disk_val=$1
    if [ -z "$disk_val" ]; then echo "UNKNOWN"; return; fi
    if [ "$disk_val" -gt 95 ]; then echo "CRITICAL"; elif [ "$disk_val" -gt 85 ]; then echo "WARNING"; else echo "OK"; fi
}

#  محرك الحالة العام واختباره بالقيم الممررة
analyze_metrics() {
    local cpu
    cpu=$1
    local ram
    ram=$2
    local disk
    disk=$3

    # حماية لو تم تشغيل الملف لوحده بدون قيم
    if [ -z "$cpu" ] || [ -z "$ram" ] || [ -z "$disk" ]; then
        echo "[ERROR] Usage: bash analyzer.sh <cpu> <ram> <disk>"
        return 1
    fi

    # إجراء التحليلات الفردية
    local cpu_status ram_status disk_status
    cpu_status=$(analyze_cpu "$cpu")
    ram_status=$(analyze_ram "$ram")
    disk_status=$(analyze_disk "$disk")

    # تحديد الحالة العامة للنظام (System Status) بناءً على الأولويات
    local system_status
    system_status="OK"
    if [ "$cpu_status" == "CRITICAL" ] || [ "$ram_status" == "CRITICAL" ] || [ "$disk_status" == "CRITICAL" ]; then
        system_status="CRITICAL"
    elif [ "$cpu_status" == "WARNING" ] || [ "$ram_status" == "WARNING" ] || [ "$disk_status" == "WARNING" ]; then
        system_status="WARNING"
    fi

    # طباعة التقرير النهائي للمحرك
    echo "-----------------------------------"
    echo "📊 System Analysis Report:"
    echo "   CPU Status  : $cpu_status ($cpu%)"
    echo "   RAM Status  : $ram_status ($ram%)"
    echo "   Disk Status : $disk_status ($disk%)"
    echo "   SYSTEM STATUS => $system_status"
    echo "-----------------------------------"

    log_info "Analysis complete. System Status: $system_status"
}

analyze_metrics 20 85 40