#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CSV_FILE="$SCRIPT_DIR/../../data/metrics.csv"

initialize_csv() {
    # التأكد من وجود المجلد
    mkdir -p "$(dirname "$CSV_FILE")"
    
    # كتابة الـ Header لو الملف فارغ (Task 55)
    if [ ! -s "$CSV_FILE" ]; then
        echo "Timestamp,CPU_Usage,RAM_Usage,Disk_Usage" > "$CSV_FILE"
        echo "[INFO] CSV file initialized with headers."
    fi
}

log_to_csv() {
    # 1. توليد التوقيت الحالي (Task 56)
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # 2. جلب قيم الكوليكتورز (Tasks 57, 58, 59)
    cpu_usage=$(bash "$SCRIPT_DIR/../collectors/cpu.sh")
    ram_usage=$(bash "$SCRIPT_DIR/../collectors/memory.sh")
    disk_usage=$(bash "$SCRIPT_DIR/../collectors/disk.sh")

    # حماية بسيطة للتأكد من عدم كتابة قيم فارغة
    if [ -z "$cpu_usage" ] || [ -z "$ram_usage" ] || [ -z "$disk_usage" ]; then
        echo "[ERROR] Failed to collect all metrics. Skipping write."
        return 1
    fi

    # 3. ضخ السطر بالكامل داخل ملف الـ CSV فعلياً (Task 60)
    echo "$timestamp,$cpu_usage,$ram_usage,$disk_usage" >> "$CSV_FILE"
    echo "[SUCCESS] Metrics logged to CSV successfully."
}

# تشغيل النظام للاختبار
initialize_csv
log_to_csv