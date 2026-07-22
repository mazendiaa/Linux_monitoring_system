#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# استدعاء ملف الـ Logger (مع وجود دالة احتياطية)
if [ -f "$SCRIPT_DIR/../utils/logger.sh" ]; then
   # shellcheck disable=SC1091
    source "$SCRIPT_DIR/../utils/logger.sh"
else
    log_info() { echo "[INFO] $*"; }
fi

collect_ram_usage() {
    #  قراءة السطور الخام
    mem_total_raw=$(grep '^MemTotal:' /proc/meminfo)
    mem_avail_raw=$(grep '^MemAvailable:' /proc/meminfo)

    #  استخراج الأرقام الصافية
    mem_total=$(echo "$mem_total_raw" | awk '{print $2}')
    mem_available=$(echo "$mem_avail_raw" | awk '{print $2}')

    # حماية من القسمة على صفر (في حال حدوث أي خطأ غير متوقع في ملف النظام)
    if [ -z "$mem_total" ] || [ "$mem_total" -eq 0 ]; then
        echo "0"
        return
    fi

    #  الحسابات والنسبة المئوية
    mem_used=$((mem_total - mem_available))
    ram_usage=$((mem_used * 100 / mem_total))

    #  تسجيل النتيجة النهائية في الـ Log
    log_info "RAM Usage calculated successfully: $ram_usage%"

    # إرجاع القيمة الصافية فقط
    echo "$ram_usage"
}

collect_ram_usage