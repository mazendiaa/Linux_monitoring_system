#!/bin/bash

# دالة لجلب وتنسيق العمليات المستهلكة للـ CPU 
get_top_cpu_processes() {
    echo -e "PID     %CPU    COMMAND"
    ps -eo pid,%cpu,comm --sort=-%cpu | awk '
    NR>1 && NR<=6 {
    
    printf "%-7s %-5s   %-16.60s\n", $1, $2"%", $3
}'
}                                      

# دالة لجلب وتنسيق العمليات المستهلكة للـ RAM
get_top_ram_processes() {
    echo -e "PID     %MEM    COMMAND"
    ps -eo pid,%mem,comm --sort=-%mem | awk '
    NR>1 && NR<=6 {
    
    printf "%-7s %-5s   %-16.60s\n", $1, $2"%", $3
}'
}

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

show_analysis