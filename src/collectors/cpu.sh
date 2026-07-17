#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# استدعاء ملف الـ Logger (لو مش موجود بنعمل فانكشن احتياطية عشان الكود ما يقفش)
if [ -f "$SCRIPT_DIR/../utils/logger.sh" ]; then
    # shellcheck disable=SC1091
    source "$SCRIPT_DIR/../utils/logger.sh"
else
    log_info() { echo "[INFO] $*"; }
fi

collect_cpu_usage() {
    # [Task 30] اللقطة الأولى
    read -r _ user1 nice1 system1 idle1 _ < <(grep '^cpu ' /proc/stat)
    total1=$((user1 + nice1 + system1 + idle1))
    log_info "Snapshot 1 taken. Total1: $total1, Idle1: $idle1"

    # [Task 31] الانتظار (ثانيتين)
    sleep_time=${REFRESH_INTERVAL:-1} 
    sleep "$sleep_time"

    # [Task 32] اللقطة الثانية
    read -r _ user2 nice2 system2 idle2 _ < <(grep '^cpu ' /proc/stat)
    total2=$((user2 + nice2 + system2 + idle2))
    log_info "Snapshot 2 taken. Total2: $total2, Idle2: $idle2"
    
    # [Task 33] حساب الفرق
    diff_total=$((total2 - total1))
    diff_idle=$((idle2 - idle1))

    # حماية من القسمة على صفر (لو مفيش تغيير في الوقت)
    if [ "$diff_total" -eq 0 ]; then
        echo "0"
        return
    fi

    # [Task 34] حساب النسبة
    cpu_usage=$(( (diff_total - diff_idle) * 100 / diff_total ))
    log_info "CPU Usage calculated successfully: $cpu_usage%"

    # ==========================================
    # [Task 35] إرجاع القيمة فقط
    # ==========================================
    echo "$cpu_usage"
}

# تشغيل الفانكشن (الآن هتطبع الرقم الصافي فقط في التيرمنال)
collect_cpu_usage