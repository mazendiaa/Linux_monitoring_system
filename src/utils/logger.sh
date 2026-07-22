#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../../logs"
LOG_FILE="$LOG_DIR/app.log"

# إنشاء مجلد الـ Logs لو مش موجود
mkdir -p "$LOG_DIR"

# دالة التحقق الآمن قبل الكتابة (صلاحيات + مساحة القرص)
safe_to_write() {
    # التحقق من المساحة المتاحة على القرص
    local disk_usage
    disk_usage=$(df -P "$LOG_DIR" | awk 'NR==2 {print $5}' | tr -d '%')
    
    if [ "$disk_usage" -ge 98 ]; then
        # القرص ممتلئ تقريباً، نمنع الكتابة لتجنب الانهيار
        echo -e "\033[0;31m[CRITICAL SYSTEM WARNING] Write suspended! Disk is 98%+ Full.\033[0m" >&2
        return 1
    fi

    # التحقق من صلاحية الكتابة للملف (لو موجود) أو المجلد
    if [ -f "$LOG_FILE" ]; then
        if [ ! -w "$LOG_FILE" ]; then
            echo "[EMERGENCY] Log file is not writable!" >&2
            return 1
        fi
    else
        if [ ! -w "$LOG_DIR" ]; then
            echo "[EMERGENCY] Log directory is not writable!" >&2
            return 1
        fi
    fi

    return 0
}

log_message() {
    local level=$1
    shift
    local msg="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # لو الفحص الأمني تمام، نكتب في اللوج
    if safe_to_write; then
        echo "$timestamp [$level] $msg" >> "$LOG_FILE"
    else
        # طباعة المشكلة على الـ stderr مباشرة
        echo "$timestamp [EMERGENCY_SHIELD] Could not write to log file!" >&2
    fi
}

log_info() {
    log_message "INFO" "$*"
}

log_warning() {
    log_message "WARNING" "$*"
}

log_error() {
    log_message "ERROR" "$*"
}