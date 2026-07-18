#!/usr/bin/env bash
set -o pipefail

IFS=' ' read -r status pct < <(
  powershell.exe -NoProfile -Command \
    '$b = Get-CimInstance -ClassName Win32_Battery; "$($b.BatteryStatus) $($b.EstimatedChargeRemaining)"' \
    2>/dev/null | tr -d '\r'
)

case "$status" in
  2|3|4|5|6|7|8|9|11) icon="⚡" ;;
  *)
    if [ -n "$pct" ] && [ "$pct" -lt 20 ] 2>/dev/null; then
      icon="🪫"
    else
      icon="🔋"
    fi
    ;;
esac

printf '%s %s%%\n' "$icon" "${pct:-?}"
