#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../../config/config.conf"
ALERTS_SCRIPT="$SCRIPT_DIR/../alerts/alerts.sh"
PROCESS_SCRIPT="$SCRIPT_DIR/../analyzers/process_analyzer.sh"
ADVANCED_SCRIPT="$SCRIPT_DIR/../collectors/advanced_metrics.sh"
#CSV_FILE="$SCRIPT_DIR/../../data/metrics.csv"

# [Task 109] حماية وتحميل ملف الإعدادات بقيم افتراضية صارمة في حال غيابه
REFRESH_INTERVAL=2
# CPU_THRESHOLD=90
# RAM_THRESHOLD=80
# DISK_THRESHOLD=85

if [ -f "$CONFIG_FILE" ]; then
    # shellcheck disable=SC1090
    source "$CONFIG_FILE"
else
    # لو الملف مش موجود، بنكتب تحذير في الـ Log ونكمل بالقيم الافتراضية
    if [ -f "$SCRIPT_DIR/../utils/logger.sh" ]; then
        # shellcheck disable=SC1091
        source "$SCRIPT_DIR/../utils/logger.sh"
        log_warning "Config file missing at $CONFIG_FILE. Using safe defaults."
    fi
fi

# [Task 109] التحقق الآمن من وجود سكريبتات المكونات الأخرى قبل عمل source

# shellcheck disable=SC1090,SC1091
if [ -f "$ALERTS_SCRIPT" ]; then
    source "$ALERTS_SCRIPT" > /dev/null 2>&1
fi

# shellcheck disable=SC1090,SC1091
if [ -f "$PROCESS_SCRIPT" ]; then
    source "$PROCESS_SCRIPT" > /dev/null 2>&1
fi

# shellcheck disable=SC1090,SC1091
if [ -f "$ADVANCED_SCRIPT" ]; then
    source "$ADVANCED_SCRIPT" > /dev/null 2>&1
fi

# تعريف ألوان ANSI
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# دالة رسم شريط التحميل البصري مع حماية ضد القيم غير الرقمية أو الفارغة (Task 110)
draw_progress_bar() {
    local val=$1
    # حماية: لو القيمة فارغة أو ليست رقماً، نعتبرها صفر
    if [ -z "$val" ] || ! [[ "$val" =~ ^[0-9]+$ ]]; then 
        val=0 
    fi

    local bar_size=20
    local filled=$(( val * bar_size / 100 ))
    local empty=$(( bar_size - filled ))

    local bar_color=$GREEN
    if [ "$val" -gt 90 ]; then
        bar_color=$RED
    elif [ "$val" -gt 75 ]; then
        bar_color=$YELLOW
    fi

    local bar=""
    for ((i=0; i<filled; i++)); do bar="${bar}${bar_color}|${NC}"; done
    for ((i=0; i<empty; i++)); do bar="${bar}-"; done

    echo -e "[$bar] ${bar_color}${val}%${NC}"
}

draw_header() {
    tput cup 0 0
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${CYAN}    🚀 LINUX SYSTEM REAL-TIME MONITORING COCKPIT   ${NC}"
    echo -e "${CYAN}====================================================${NC}"
    local current_time
    current_time=$(date '+%Y-%m-%d %H:%M:%S')
    
    local uptime_val="N/A"
    if declare -f get_system_uptime > /dev/null; then
        uptime_val=$(get_system_uptime)
    fi
    echo -e "    ⏱️  Time: ${YELLOW}$current_time${NC}  |  🕒 Uptime: ${GREEN}$uptime_val${NC}"
    echo -e "${CYAN}====================================================${NC}"
}

display_dashboard() {
    draw_header

    # [Task 109] جلب القيم الحقيقية مع التأكد الآمن من وجود السكريبتات
    local cpu_usage=0
    local ram_usage=0
    local disk_usage=0

    if [ -f "$SCRIPT_DIR/../collectors/cpu.sh" ]; then
        cpu_usage=$(bash "$SCRIPT_DIR/../collectors/cpu.sh")
    fi
    if [ -f "$SCRIPT_DIR/../collectors/memory.sh" ]; then
        ram_usage=$(bash "$SCRIPT_DIR/../collectors/memory.sh")
    fi
    if [ -f "$SCRIPT_DIR/../collectors/disk.sh" ]; then
        disk_usage=$(bash "$SCRIPT_DIR/../collectors/disk.sh")
    fi

    draw_header

    # 1. عرض الموارد الرئيسية
    echo -e "    📊 SYSTEM METRICS:"
    echo -e "       CPU Usage  : $(draw_progress_bar "$cpu_usage")"
    echo -e "       RAM Usage  : $(draw_progress_bar "$ram_usage")"
    echo -e "       Disk Usage : $(draw_progress_bar "$disk_usage")"
    echo -e "${CYAN}====================================================${NC}"

    # 2. عرض المقاييس المتقدمة
    local load_val="N/A"
    local net_val="N/A"
    if declare -f get_load_average > /dev/null; then load_val=$(get_load_average); fi
    if declare -f get_network_stats > /dev/null; then net_val=$(get_network_stats); fi

    echo -e "    ⚙️  ADVANCED METRICS:"
    echo -e "       Load Average : ${YELLOW}$load_val${NC}"
    echo -e "       Network I/O  : ${GREEN}$net_val${NC}"
    
    local num_cores
    num_cores=$(nproc 2>/dev/null || echo 1)
    local load_1m
    load_1m=$(echo "$load_val" | cut -d',' -f1 | tr -d ' ' 2>/dev/null || echo 0)
    
    if [[ "$load_1m" =~ ^[0-9.]+$ ]] && (( $(echo "$load_1m > $num_cores" | bc -l 2>/dev/null || echo 0) )); then
        echo -e "       ${RED}⚠️  CPU SATURATION WARNING: Load avg ($load_1m) exceeds Core Count ($num_cores)!${NC}"
    fi
    echo -e "${CYAN}====================================================${NC}"

    # 3. عرض العمليات الأكثر استهلاكاً مع التحقق من وجود الدوال
    echo -e "    🔥 TOP CPU PROCESSES:             💾 TOP RAM PROCESSES:"
    echo -e "    ---------------------             ---------------------"
    
    if declare -f get_top_cpu_processes > /dev/null && declare -f get_top_ram_processes > /dev/null; then
        mapfile -t cpu_procs < <(get_top_cpu_processes 2>/dev/null | head -n 3)
        mapfile -t ram_procs < <(get_top_ram_processes 2>/dev/null | head -n 3)

        for i in {0..2}; do
            local cpu_line="${cpu_procs[$i]:-}"
            local ram_line="${ram_procs[$i]:-}"
            printf "    %-30s    %-30s\n" "$cpu_line" "$ram_line"
        done
    else
        echo -e "    ⚠️  ${RED}Process Analyzer functions not loaded!${NC}"
    fi
    echo -e "${CYAN}====================================================${NC}"

    # 4. تحليل الحالة العامة
    if [ -f "$SCRIPT_DIR/../analyzers/analyzer.sh" ]; then
        local raw_status
        raw_status=$(bash "$SCRIPT_DIR/../analyzers/analyzer.sh" "$cpu_usage" "$ram_usage" "$disk_usage" 2>/dev/null | grep "SYSTEM STATUS")
        local status_word
        status_word=$(echo "$raw_status" | awk -F '=> ' '{print $2}')

        local color=$GREEN
        if [ "$status_word" == "WARNING" ]; then
            color=$YELLOW
        elif [ "$status_word" == "CRITICAL" ]; then
            color=$RED
        fi

        echo -e "   SYSTEM STATUS => ${color}${status_word:-OK}${NC}"
    else
        echo -e "   SYSTEM STATUS => ${GREEN}OK${NC} (Analyzer script missing)"
    fi
    echo -e "${CYAN}====================================================${NC}"

    # 5. التنبيهات الحية
    echo -e "📢 Live Alerts Area:"
    if declare -f check_resource_limits > /dev/null; then
        check_resource_limits "$cpu_usage" "$ram_usage" "$disk_usage"
    else
        echo "   [No active alerts - System Healthy]"
    fi
    echo -e "${CYAN}====================================================${NC}"
}

# تهيئة التيرمنال
# تهيئة التيرمنال
clear

while true; do
    # [Task 113] فحص سريع لمساحة القرص قبل تحديث الشاشة
    DISK_FULL_CHECK=$(df -P / | awk 'NR==2 {print $5}' | tr -d '%')
    if [ "$DISK_FULL_CHECK" -ge 98 ]; then
        clear
        echo -e "\033[0;31m====================================================${NC}"
        echo -e "\033[0;31m🚨 EMERGENCY: MONITORING SUSPENDED - DISK IS FULL! (${DISK_FULL_CHECK}%)\033[0m"
        echo -e "\033[0;31m====================================================${NC}"
        echo "Please free up space on your system to resume monitoring."
        sleep 5
        continue
    fi

    display_dashboard
    sleep "$REFRESH_INTERVAL"
done