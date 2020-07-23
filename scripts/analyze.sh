#!/bin/bash
SCRIPT_DIR=$(dirname $(realpath "$0"))
cd "$SCRIPT_DIR/.."

if [ "$1" != "" ]; then
  REPORT_DIR="$1"
else
  echo "$0 reports_directory"
  exit 1
fi

pushd $REPORT_DIR

for f in *.txt; do
  name=${f%.txt}

  n=$(tail -n +2 $f | cut -d, -f1 | st --count)
  min=$(tail -n +2 $f | cut -d, -f1 | st --min)
  max=$(tail -n +2 $f | cut -d, -f1 | st --max)
  duration=$(tail -n +2 $f | cut -d, -f8| st --max)
  successes=$(tail -n +2 $f | cut -d, -f7| st --count)
  failures=$((n - successes))
  success_rate=$((successes / n * 100))
  failure_rate=$((failures / n * 100))
  p90=$(tail -n +2 $f | cut -d, -f1 | st --percentile=90)
  p95=$(tail -n +2 $f | cut -d, -f1 | st --percentile=95)
  p99=$(tail -n +2 $f | cut -d, -f1 | st --percentile=99)

  echo -e "$name min=${min} max=${max} duration=${duration} success=$(printf %.2f ${success_rate})% failure=$(printf %.2f ${failure_rate})% p90=${p90} p95=${p95} p99=${p99}"
done

popd
