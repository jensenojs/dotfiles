#!/bin/sh
# macOS 系统指标采集脚本
# 输出格式: CPU=xx MEM=yy DISK=zz RX=aaaa TX=bbbb

# CPU 使用率
# 优先使用 top,失败时降级到 ps
cpu=$(LC_ALL=C top -l 1 -n 0 2>/dev/null | awk '
    /CPU usage/ {
        # 字段示例: CPU usage: 23.40% user, 14.64% sys, 61.95% idle
        user=$3; sys=$5
        gsub("%", "", user)
        gsub("%", "", sys)
        user += 0
        sys += 0
        printf "%d\n", int(user + sys + 0.5)
        exit
    }
')
if [ -z "$cpu" ]; then
    cpu=$(ps -A -o %cpu 2>/dev/null | awk 'NR>1 {sum+=$1} END {printf "%d\n", sum}')
fi
cpu=${cpu:-0}

# 内存使用率
# 优先使用 memory_pressure,失败时降级到 vm_stat
mem=$(memory_pressure 2>/dev/null | awk '
    /System-wide memory free percentage:/ {
        gsub(/%/,"",$5)
        printf "%d\n", 100 - $5
        exit
    }
')
if [ -z "$mem" ]; then
    mem=$(vm_stat 2>/dev/null | awk '
        /Pages active/ {gsub(/[^0-9]/,"",$3); active=$3}
        /Pages wired/ {gsub(/[^0-9]/,"",$3); wired=$3}
        /Pages speculative/ {gsub(/[^0-9]/,"",$3); speculative=$3}
        /Pages free/ {gsub(/[^0-9]/,"",$3); free=$3}
        END {
            used = active + wired
            total = active + wired + speculative + free
            if (total > 0) printf "%d\n", (used / total) * 100
        }
    ')
fi
mem=${mem:-0}

# 磁盘使用率
disk=$(df -P . 2>/dev/null | awk 'NR==2 {gsub(/%/,"",$5); print $5}')
disk=${disk:-0}

# 网络流量统计(累计字节数)
read rx tx <<EOF
$(netstat -ib 2>/dev/null | awk '
    NR>1 && $1 !~ /^lo/ && $1 !~ /^utun/ {
        rx+=$7
        tx+=$10
    }
    END {
        if(rx=="") rx=0
        if(tx=="") tx=0
        printf "%.0f %.0f\n", rx, tx
    }
')
EOF
rx=${rx:-0}
tx=${tx:-0}

# 输出结果
printf "CPU=%s MEM=%s DISK=%s RX=%s TX=%s\n" "$cpu" "$mem" "$disk" "$rx" "$tx"
