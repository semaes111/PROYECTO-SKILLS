#!/usr/bin/env bash
set -u
printf 'OS: '; uname -srm
printf 'CPU: '; (nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo unknown)
printf 'RAM: '; (free -h 2>/dev/null | awk '/Mem:/{print $2}' || sysctl -n hw.memsize 2>/dev/null || echo unknown)
printf 'GPU: '; (nvidia-smi --query-gpu=name,memory.total --format=csv,noheader 2>/dev/null || system_profiler SPDisplaysDataType 2>/dev/null | grep -E 'Chipset Model|VRAM' | head || echo none)
command -v ffmpeg >/dev/null && ffmpeg -version | head -1 || echo 'FFmpeg: missing'
command -v python3 >/dev/null && python3 --version || echo 'Python: missing'
command -v node >/dev/null && node --version || echo 'Node: missing'
