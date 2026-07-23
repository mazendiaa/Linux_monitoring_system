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
    #  اللقطة الأولى
    read -r _ user1 nice1 system1 idle1 _ < <(grep '^cpu ' /proc/stat)
    total1=$((user1 + nice1 + system1 + idle1))
    log_info "Snapshot 1 taken. Total1: $total1, Idle1: $idle1"

    sleep_time=${REFRESH_INTERVAL:-1} 
    sleep "$sleep_time"

    #  اللقطة الثانية
    read -r _ user2 nice2 system2 idle2 _ < <(grep '^cpu ' /proc/stat)
    total2=$((user2 + nice2 + system2 + idle2))
    log_info "Snapshot 2 taken. Total2: $total2, Idle2: $idle2"
    
    #  حساب الفرق
    diff_total=$((total2 - total1))
    diff_idle=$((idle2 - idle1))

    # حماية من القسمة على صفر (لو مفيش تغيير في الوقت)
    if [ "$diff_total" -eq 0 ]; then
        echo "0"
        return
    fi

    #  حساب النسبة
    cpu_usage=$(( (diff_total - diff_idle) * 100 / diff_total ))
    log_info "CPU Usage calculated successfully: $cpu_usage%"

    #  إرجاع القيمة فقط
    echo "$cpu_usage"
}

collect_cpu_usage