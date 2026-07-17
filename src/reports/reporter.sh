#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CSV_FILE="$SCRIPT_DIR/../../data/metrics.csv"
OUTPUT_DIR="$SCRIPT_DIR/../../reports"
OUTPUT_FILE="$OUTPUT_DIR/performance_report.txt"

# التحقق من وجود ملف البيانات
if [ ! -f "$CSV_FILE" ]; then
    echo "[ERROR] No metrics data found at $CSV_FILE. Please run the collector or dashboard first."
    exit 1
fi

# إنشاء مجلد التقارير لو مش موجود
mkdir -p "$OUTPUT_DIR"

# دالة حساب المتوسطات (Averages)
calculate_averages() {
    awk -F',' '
    NR > 1 {
        cpu_sum += $2;
        ram_sum += $3;
        count++;
    }
    END {
        if (count > 0) {
            printf "%.2f%%|%.2f%%", cpu_sum/count, ram_sum/count;
        } else {
            printf "0.00%|0.00%";
        }
    }' "$CSV_FILE"
}

# دالة حساب أعلى قيم استهلاك (Peaks)
calculate_peaks() {
    awk -F',' '
    NR > 1 {
        if ($2 > cpu_max) cpu_max = $2;
        if ($3 > ram_max) ram_max = $3;
        if ($4 > disk_max) disk_max = $4;
    }
    END {
        printf "%.2f%%|%.2f%%|%.2f%%", cpu_max, ram_max, disk_max;
    }' "$CSV_FILE"
}

# [Task 108] دالة توليد وتصدير التقرير
generate_report() {
    IFS='|' read -r avg_cpu avg_ram < <(calculate_averages)
    IFS='|' read -r peak_cpu peak_ram peak_disk < <(calculate_peaks)

    local report_time
    report_time=$(date '+%Y-%m-%d %H:%M:%S')

    # بناء التقرير وتوجيهه للشاشة وللملف الخارجي في نفس الوقت باستخدام tee
    {
        echo "===================================================="
        echo "📊       SYSTEM PERFORMANCE METRICS REPORT          "
        echo "===================================================="
        echo "📅 Generated At : $report_time"
        echo "📁 Source Data  : metrics.csv"
        echo "===================================================="
        echo "📈 AVERAGES OVER TIME:"
        echo "   • Average CPU Usage : $avg_cpu"
        echo "   • Average RAM Usage : $avg_ram"
        echo "----------------------------------------------------"
        echo "🔥 PEAK UTILIZATION (MAX VALUES REACHED):"
        echo "   • Peak CPU Usage    : $peak_cpu"
        echo "   • Peak RAM Usage    : $peak_ram"
        echo "   • Peak Disk Usage   : $peak_disk"
        echo "===================================================="
    } | tee "$OUTPUT_FILE"

    echo -e "\n📝 [SUCCESS] Report exported successfully to: \033[0;32mreports/performance_report.txt\033[0m"
}

generate_report