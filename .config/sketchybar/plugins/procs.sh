#!/bin/bash
# Fill a cpu/memory popup with the top 5 processes, then toggle it. $1 = cpu|mem
if [ "$1" = "mem" ]; then parent="memory"; col="pmem"; sortflag="-m"
else parent="cpu"; col="pcpu"; sortflag="-r"; fi

i=0
while IFS=$'\t' read -r pct name; do
  [ "$i" -ge 5 ] && break
  sketchybar --set "$parent.proc.$i" drawing=on \
    label="$(printf '%-15.15s %5s%%' "$name" "$pct")" 2>/dev/null
  i=$((i + 1))
done < <(ps -Aco "$col,comm" $sortflag 2>/dev/null | awk 'NR>1{pct=$1;$1="";sub(/^[ \t]+/,"");printf "%s\t%s\n",pct,$0}')

while [ "$i" -lt 5 ]; do
  sketchybar --set "$parent.proc.$i" drawing=off 2>/dev/null
  i=$((i + 1))
done
