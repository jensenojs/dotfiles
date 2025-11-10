#!/bin/sh
# Linux 系统指标采集脚本
# 输出格式: CPU=xx MEM=yy DISK=zz RX=aaaa TX=bbbb

# CPU 使用率
# 优先读取 /proc/stat(更高效),失败时降级到 top
if [ -r /proc/stat ]; then
    # 读取 /proc/stat 计算 CPU 使用率
    # 格式: cpu user nice system idle iowait irq softirq steal guest guest_nice
    cpu=$(awk '
        /^cpu / {
            user=$2; nice=$3; system=$4; idle=$5; iowait=$6
            irq=$7; softirq=$8; steal=$9
            
            # 总时间 = 所有字段之和
            total = user + nice + system + idle + iowait + irq + softirq + steal
            
            # 空闲时间 = idle + iowait
            idle_total = idle + iowait
            
            if (total > 0) {
                usage = ((total - idle_total) / total) * 100
                printf "%d\n", usage
            }
            exit
        }
    ' /proc/stat 2>/dev/null)
fi

# 降级到 top
if [ -z "$cpu" ]; then
    cpu=$(LANG=C top -bn1 2>/dev/null | awk -F',' '
        /Cpu\(s\)/ {
            for (i = 1; i <= NF; i++) {
                if ($i ~ /id/) {
                    gsub(/[^0-9.]/,"",$i)
                    printf "%d\n", (100 - $i + 0.5)
                    exit
                }
            }
        }
    ')
fi
cpu=${cpu:-0}

# 内存使用率
mem=$(awk '
    /^MemTotal:/ {total=$2}
    /^MemAvailable:/ {avail=$2}
    END {
        if (total>0 && avail>0) {
            printf "%d\n", ((total-avail)/total)*100
        }
    }
' /proc/meminfo 2>/dev/null)
mem=${mem:-0}

# 磁盘使用率
disk=$(df -P . 2>/dev/null | awk 'NR==2 {gsub(/%/,"",$5); print $5}')
disk=${disk:-0}

# 网络流量统计(累计字节数)
read rx tx <<EOF
$(awk '
    NR>2 {
        sub(/:/,"",$1)
        if ($1!="lo") {
            rx+=$2
            tx+=$10
        }
    }
    END {
        if(rx=="") rx=0
        if(tx=="") tx=0
        printf "%.0f %.0f\n", rx, tx
    }
' /proc/net/dev 2>/dev/null)
EOF
rx=${rx:-0}
tx=${tx:-0}

# 输出结果
printf "CPU=%s MEM=%s DISK=%s RX=%s TX=%s\n" "$cpu" "$mem" "$disk" "$rx" "$tx"
