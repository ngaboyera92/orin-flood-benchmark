#!/usr/bin/env bash
set -euo pipefail

mkdir -p engines logs

MODEL="models/model_student.onnx"

if [ ! -f "$MODEL" ]; then
  echo "ERROR: ONNX model not found at $MODEL"
  exit 1
fi

if [ -x /usr/src/tensorrt/bin/trtexec ]; then
  TRTEXEC="/usr/src/tensorrt/bin/trtexec"
else
  TRTEXEC="$(command -v trtexec)"
fi

echo "Using trtexec: $TRTEXEC"

HELP="$($TRTEXEC --help 2>&1 || true)"

if echo "$HELP" | grep -q "memPoolSize"; then
  MEM_OPT="--memPoolSize=workspace:2048"
else
  MEM_OPT="--workspace=2048"
fi

echo "Using memory option: $MEM_OPT"

echo "===== BUILD FP32 ENGINE ====="
$TRTEXEC \
  --onnx="$MODEL" \
  --saveEngine=engines/model_student_fp32.engine \
  $MEM_OPT \
  --verbose \
  | tee logs/build_fp32.log

echo "===== BUILD FP16 ENGINE ====="
$TRTEXEC \
  --onnx="$MODEL" \
  --saveEngine=engines/model_student_fp16.engine \
  --fp16 \
  $MEM_OPT \
  --verbose \
  | tee logs/build_fp16.log

echo "===== ENGINE SIZES ====="
ls -lh engines | tee logs/engine_sizes.txt

echo "Finished building FP32 and FP16 engines."
