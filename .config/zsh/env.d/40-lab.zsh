# 实验室和课程相关环境变量 - Lab & Course Environment Variables

# ICS 2025 实验环境
_ICS_LAB="$HOME/Projects/Lab/ics2025"

[[ -d "$_ICS_LAB/nemu" ]] && export NEMU_HOME="$_ICS_LAB/nemu"
[[ -d "$_ICS_LAB/abstract-machine" ]] && export AM_HOME="$_ICS_LAB/abstract-machine"

unset _ICS_LAB