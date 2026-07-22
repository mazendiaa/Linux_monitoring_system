#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../../config/config.conf"

# استدعاء الـ Logger
if [ -f "$SCRIPT_DIR/../utils/logger.sh" ]; then
    # shellcheck disable=SC1091
    source "$SCRIPT_DIR/../utils/logger.sh"
else
    log_error() { echo "[ERROR] $*"; }
    log_warning() { echo "[WARNING] $*"; }
fi

CPU_THRESHOLD=90
RAM_THRESHOLD=80
DISK_THRESHOLD=85

if [ -f "$CONFIG_FILE" ]; then
   # shellcheck disable=SC1090
     source "$CONFIG_FILE"
fi

#  تعريف متغيرات لتخزين وقت آخر تنبيه لكل مورد (Epoch Time)
COOLDOWN_PERIOD=60

LAST_CPU_ALERT_TIME=0
LAST_RAM_ALERT_TIME=0
LAST_DISK_ALERT_TIME=0

# دالة إرسال التنبيه الفعلي وتوثيقه مع فحص الـ Cooldown
send_alert() {
    local resource=$1
    local value=$2
    local level=$3
    local current_time
    current_time=$(date +%s) 

    # تحديد وقت آخر تنبيه بناءً على المورد
    local last_alert_time
    last_alert_time=0
    if [ "$resource" == "CPU" ]; then
        last_alert_time=$LAST_CPU_ALERT_TIME
    elif [ "$resource" == "RAM" ]; then
        last_alert_time=$LAST_RAM_ALERT_TIME
    elif [ "$resource" == "Disk" ]; then
        last_alert_time=$LAST_DISK_ALERT_TIME
    fi

    # حساب الوقت المنقضي منذ آخر تنبيه
    local time_diff
    time_diff=$(( current_time - last_alert_time ))

    # لو لسه جوه فترة التبريد، اعرض التنبيه على الـ Dashboard بصرياً فقط لكن لا تكتبه في الـ Log مجدداً
    if [ "$time_diff" -lt "$COOLDOWN_PERIOD" ]; then
        # بنطبع بس في التيرمنال عشان الـ Dashboard تظل حية، لكن من غير ما نغرق الـ log
        if [ "$level" == "CRITICAL" ]; then
            echo -e "\033[0;31m[ALERT] $resource is $level ($value%) [Cooldown Active]\033[0m"
        else
            echo -e "\033[0;33m[ALERT] $resource is $level ($value%) [Cooldown Active]\033[0m"
        fi
        return 0
    fi

    # إذا تخطى فترة التبريد، قم بتحديث وقت التنبيه الأخير واكتب في الـ Log 
    if [ "$resource" == "CPU" ]; then
        LAST_CPU_ALERT_TIME=$current_time
    elif [ "$resource" == "RAM" ]; then
        LAST_RAM_ALERT_TIME=$current_time
    elif [ "$resource" == "Disk" ]; then
        LAST_DISK_ALERT_TIME=$current_time
    fi

    # توثيق في الـ Log
    local alert_msg
    alert_msg="⚠️ ALERT! $resource utilization is $level: current value is $value%"
    if [ "$level" == "CRITICAL" ]; then
        log_error "$alert_msg"
        echo -e "\033[0;31m[ALERT ENGINE - NEW LOGGED ALERT] $alert_msg\033[0m"
    else
        log_warning "$alert_msg"
        echo -e "\033[0;33m[ALERT ENGINE - NEW LOGGED ALERT] $alert_msg\033[0m"
    fi
}

check_resource_limits() {
    local cpu_val=$1
    local ram_val=$2
    local disk_val=$3

    if [ -z "$cpu_val" ] || [ -z "$ram_val" ] || [ -z "$disk_val" ]; then
        return 1
    fi

    # فحص الـ CPU
    if [ "$cpu_val" -gt "$CPU_THRESHOLD" ]; then
        send_alert "CPU" "$cpu_val" "CRITICAL"
    elif [ "$cpu_val" -gt $((CPU_THRESHOLD - 15)) ]; then
        send_alert "CPU" "$cpu_val" "WARNING"
    fi

    # فحص الـ RAM
    if [ "$ram_val" -gt "$RAM_THRESHOLD" ]; then
        send_alert "RAM" "$ram_val" "CRITICAL"
    elif [ "$ram_val" -gt $((RAM_THRESHOLD - 10)) ]; then
        send_alert "RAM" "$ram_val" "WARNING"
    fi

    # فحص الـ Disk
    if [ "$disk_val" -gt "$DISK_THRESHOLD" ]; then
        send_alert "Disk" "$disk_val" "CRITICAL"
    elif [ "$disk_val" -gt $((DISK_THRESHOLD - 10)) ]; then
        send_alert "Disk" "$disk_val" "WARNING"
    fi
}