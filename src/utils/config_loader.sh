#!/bin/bash

# مسار ملف الإعدادات
CONFIG_FILE="config/config.conf"

# دالة لتحميل الإعدادات
load_config() {
    # التأكد من وجود ملف الإعدادات
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "[ERROR] Config file not found at $CONFIG_FILE" >&2
        exit 1
    fi

    # قراءة الملف وعمل import للمتغيرات
    # استخدام source أو . لقراءة المتغيرات
    
    # shellcheck disable=SC1090
    source "$CONFIG_FILE"

    # التحقق من أن المتغيرات الأساسية تم تحميلها وليست فارغة
    if [ -z "$CPU_THRESHOLD" ] || [ -z "$RAM_THRESHOLD" ] || [ -z "$DISK_THRESHOLD" ] || [ -z "$REFRESH_INTERVAL" ]; then
        echo "[ERROR] One or more configuration variables are missing in $CONFIG_FILE" >&2
        exit 1
    fi

    echo "[INFO] Configuration loaded successfully."
}

load_config