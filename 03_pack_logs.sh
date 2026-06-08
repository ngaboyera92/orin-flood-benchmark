#!/usr/bin/env bash
set -euo pipefail

mkdir -p logs results engines

OUT="orin_logs_$(date +%Y%m%d_%H%M%S).tar.gz"

echo "Packing logs, results, and engine-size information..."

tar -czf "$OUT" \
  logs \
  results \
  engines \
  2>/dev/null || tar -czf "$OUT" logs results

echo "Created archive:"
ls -lh "$OUT"

echo
echo "To push logs to GitHub, run:"
echo "git add logs results engines $OUT"
echo "git commit -m \"Add Orin benchmark logs\""
echo "git push"
