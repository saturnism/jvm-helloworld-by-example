#!/bin/bash
SCRIPT_DIR=$(dirname $(realpath "$0"))
cd "$SCRIPT_DIR/.."

if [ "$1" != "" ]; then
  REPORT_DIR="$1"
else
  echo "$0 reports_directory [pattern]"
  exit 1
fi

PATTERN="*.txt"
if [ "$2" != "" ]; then
  PATTERN="$2"
fi


function print_header {
  echo -e "name,deploy_time,loadtest_duration,latency_min,latency_max,latency_p90,latency_p95,latency_p99,success_rate,startup_min,startup_max,startup_p90,startup_p95,startup_p99"
}

function report {
  local name="$1"
  echo -e "${name}" >&2

  n=$(tail -n +2 $f | cut -d, -f1 | st --count)
  min=$(tail -n +2 $f | cut -d, -f1 | st --min)
  max=$(tail -n +2 $f | cut -d, -f1 | st --max)
  duration=$(tail -n +2 $f | cut -d, -f8| st --max)
  successes=$(tail -n +2 $f | cut -d, -f7| st --count)
  failures=$((n - successes))
  success_rate=$((successes / n * 100))
  failure_rate=$((failures / n * 100))
  p90=$(tail -n +2 $f | cut -d, -f1 | st --percentile=90 --format="%.2f")
  p95=$(tail -n +2 $f | cut -d, -f1 | st --percentile=95 --format="%.2f")
  p99=$(tail -n +2 $f | cut -d, -f1 | st --percentile=99 --format="%.2f")

  deploy_time=$(grep real ${name}.time | sed -e 's/^real[[:space:]]*//')

  s_unit=$(head -n1 "${name}.log" | sed -e 's/.* in \(.*\)/\1/' | cut -d" " -f2)
  s_min=$(cat "${name}.log" | sed -e 's/.* in \(.*\)/\1/' | cut -d" " -f1 | st --min --format="%.2f")
  s_max=$(cat "${name}.log" | sed -e 's/.* in \(.*\)/\1/' | cut -d" " -f1 | st --max --format="%.2f")
  s_p90=$(cat "${name}.log" | sed -e 's/.* in \(.*\)/\1/' | cut -d" " -f1 | st --percentile=90 --format="%.2f")
  s_p95=$(cat "${name}.log" | sed -e 's/.* in \(.*\)/\1/' | cut -d" " -f1 | st --percentile=95 --format="%.2f")
  s_p99=$(cat "${name}.log" | sed -e 's/.* in \(.*\)/\1/' | cut -d" " -f1 | st --percentile=99 --format="%.2f")

  if [ "${s_unit}" == "ms" ]; then
    s_min=$(bc <<< "scale=2; ${s_min}/1000 ")
    s_max=$(bc <<< "scale=2; ${s_max}/1000 ")
    s_p90=$(bc <<< "scale=2; ${s_p90}/1000 ")
    s_p95=$(bc <<< "scale=2; ${s_p95}/1000 ")
    s_p99=$(bc <<< "scale=2; ${s_p99}/1000 ")
  fi

  echo -e "${name},${deploy_time},${duration},${min},${max},${p90},${p95},${p99},$(printf %.2f ${success_rate})%,${s_min},${s_max},${s_p90},${s_p95},${s_p99}"

  echo -e "- Startup Time: min=${s_min} max=${s_max} p90=${s_p90} p95=${s_p95} p99=${s_p99}" >&2
  echo -e "- Latency: min=${min} max=${max} p90=${p90} p95=${p95} p99=${p99}" >&2
  echo -e "- Success Rate: success=$(printf %.2f ${success_rate})% failure=$(printf %.2f ${failure_rate})%" >&2
  echo -e "- Durations: deploy_time=${deploy_time} loadtest_duration=${duration}" >&2
}

pushd $REPORT_DIR >&2

print_header
for f in $PATTERN; do
  name=${f%.txt}
  report "$name"
done
popd >&2
