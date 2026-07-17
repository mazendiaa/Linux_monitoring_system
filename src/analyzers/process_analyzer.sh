#!/bin/bash

# دالة لجلب وتنسيق العمليات المستهلكة للـ CPU (Task 93)
get_top_cpu_processes() {
    echo -e "PID     %CPU    COMMAND"
    # جلب العمليات وترتيبها تنازلياً، مع تخطي سطر الهيدر الخاص بـ ps وعرض أول 5 عمليات فقط
    # ps -eo pid,%cpu,cmd --sort=-%cpu | grep -v "PID" | head -n 5 | awk '{print $1 "     " $2 "%    " $3}'
    ps -eo pid,%cpu,cmd --sort=-%cpu | awk 'NR>1 && NR<=6 {print $1 "     " $2 "%    " $3}'
}

# دالة لجلب وتنسيق العمليات المستهلكة للـ RAM (Task 94)
get_top_ram_processes() {
    echo -e "PID     %MEM    COMMAND"
    # جلب العمليات وترتيبها تنازلياً، مع تخطي سطر الهيدر الخاص بـ ps وعرض أول 5 عمليات فقط
    # ps -eo pid,%mem,cmd --sort=-%mem | grep -v "PID" | head -n 5 | awk '{print $1 "     " $2 "%    " $3}'
    ps -eo pid,%mem,cmd --sort=-%mem | awk 'NR>1 && NR<=6 {print $1 "     " $2 "%    " $3}'
}

# [Task 95] عرض وتنسيق النتائج للاختبار
show_analysis() {
    echo "==========================================="
    echo "🔥 TOP 5 CPU CONSUMING PROCESSES:"
    echo "==========================================="
    get_top_cpu_processes
    echo ""
    echo "💾 TOP 5 RAM CONSUMING PROCESSES:"
    echo "==========================================="
    get_top_ram_processes
    echo "==========================================="
}

# تشغيل العرض التجريبي
show_analysis