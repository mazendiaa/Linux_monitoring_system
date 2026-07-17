#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# استدعاء ملف الـ Logger
if [ -f "$SCRIPT_DIR/../utils/logger.sh" ]; then
    # shellcheck disable=SC1091
    source "$SCRIPT_DIR/../utils/logger.sh"
else
    log_info() { echo "[INFO] $*"; }
fi

collect_disk_usage() {
    # 1. جلب السطر الخام (Task 48)
    disk_raw=$(df -P / | tail -n 1)

    # 2. استخراج نسبة الاستهلاك (Task 49)
    disk_usage=$(echo "$disk_raw" | awk '{print $5}' | tr -d '%')

    # حماية من القيم الفارغة
    if [ -z "$disk_usage" ]; then
        echo "0"
        return
    fi

    # 3. تسجيل النتيجة في الـ Log (Task 52)
    log_info "Disk Usage calculated successfully: $disk_usage%"

    # 4. إرجاع القيمة الصافية فقط (Task 53)
    echo "$disk_usage"
}

# تشغيل الفانكشن
collect_disk_usage  