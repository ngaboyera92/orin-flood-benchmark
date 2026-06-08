#!/usr/bin/env bash
set -euo pipefail

MODE_NAME="${1:-unknown_mode}"
PRECISION="${2:-fp16}"
ENGINE="${3:-engines/model_student_fp16.engine}"

mkdir -p logs results

if [ ! -f "$ENGINE" ]; then
  echo "ERROR: Engine file not found: $ENGINE"
  exit 1
fi

if [ -x /usr/src/tensorrt/bin/trtexec ]; then
  TRTEXEC="/usr/src/tensorrt/bin/trtexec"
else
  TRTEXEC="$(command -v trtexec)"
fi

echo "===== BENCHMARK START ====="
echo "Mode: $MODE_NAME"
echo "Precision: $PRECISION"
echo "Engine: $ENGINE"
date

DEVICE_LOG="logs/device_${MODE_NAME}_${PRECISION}.txt"

{
echo "===== DEVICE MODEL ====="
cat /proc/device-tree/model 2>/dev/null || true
echo

echo "===== JETSON RELEASE ====="
cat /etc/nv_tegra_release 2>/dev/null || true

echo "===== NVP MODEL ====="
sudo nvpmodel -q 2>/dev/null || nvpmodel -q 2>/dev/null || true

echo "===== TRTEXEC VERSION ====="
$TRTEXEC --version || true
} | tee "$DEVICE_LOG"

echo "===== RUN TRTEXEC ====="

$TRTEXEC \
  --loadEngine="$ENGINE" \
  --warmUp=5000 \
  --duration=120 \
  --avgRuns=10 \
  | tee "logs/trtexec_${MODE_NAME}_${PRECISION}.log"

echo "===== BENCHMARK END ====="
date
