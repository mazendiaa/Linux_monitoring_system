#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CSV_FILE="$SCRIPT_DIR/../../data/metrics.csv"

initialize_csv() {
    # التأكد من وجود المجلد
    mkdir -p "$(dirname "$CSV_FILE")"
    
    # كتابة الـ Header لو الملف فارغ 
    if [ ! -s "$CSV_FILE" ]; then
        echo "Timestamp,CPU_Usage,RAM_Usage,Disk_Usage" > "$CSV_FILE"
        echo "[INFO] CSV file initialized with headers."
    fi
}

log_to_csv() {
    #  توليد التوقيت الحالي 
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    #  جلب قيم الكوليكتورز 
    cpu_usage=$(bash "$SCRIPT_DIR/../collectors/cpu.sh")
    ram_usage=$(bash "$SCRIPT_DIR/../collectors/memory.sh")
    disk_usage=$(bash "$SCRIPT_DIR/../collectors/disk.sh")

    # حماية بسيطة للتأكد من عدم كتابة قيم فارغة
    if [ -z "$cpu_usage" ] || [ -z "$ram_usage" ] || [ -z "$disk_usage" ]; then
        echo "[ERROR] Failed to collect all metrics. Skipping write."
        return 1
    fi

    # ضخ السطر بالكامل داخل ملف الـ CSV فعلياً 
    echo "$timestamp,$cpu_usage,$ram_usage,$disk_usage" >> "$CSV_FILE"
    echo "[SUCCESS] Metrics logged to CSV successfully."
}

initialize_csv
log_to_csv