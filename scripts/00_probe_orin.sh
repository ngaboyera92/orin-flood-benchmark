#!/usr/bin/env bash
set -euo pipefail

mkdir -p logs

OUT="logs/00_probe_orin_$(date +%Y%m%d_%H%M%S).txt"

{
echo "===== DATE ====="
date

echo "===== HOSTNAME ====="
hostname

echo "===== KERNEL ====="
uname -a

echo "===== DEVICE MODEL ====="
cat /proc/device-tree/model 2>/dev/null || true
echo

echo "===== JETSON RELEASE ====="
cat /etc/nv_tegra_release 2>/dev/null || true

echo "===== PYTHON ====="
python3 --version || true

echo "===== TENSORRT TRTEXEC ====="
/usr/src/tensorrt/bin/trtexec --version || trtexec --version || true

echo "===== CUDA ====="
nvcc --version || true

echo "===== NVP MODEL ====="
sudo -n nvpmodel -q || nvpmodel -q || true

echo "===== POWER SENSORS ====="
find /sys -name "in_power*_input" 2>/dev/null || true

echo "===== DISK ====="
df -h

echo "===== MEMORY ====="
free -h

echo "===== CPU INFO ====="
lscpu || true
} | tee "$OUT"

echo "Saved probe log to $OUT"
