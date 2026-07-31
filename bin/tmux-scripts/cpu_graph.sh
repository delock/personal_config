#!/bin/bash
# Per-CPU utilization as an ASCII bar graph.
# Each character represents one CPU core; height = utilization level.
#
# Blocks (low → high): ▁ ▂ ▃ ▄ ▅ ▆ ▇ █
# Colour thresholds:  <50 % green · 50–79 % yellow · ≥80 % red

awk '
BEGIN {
    # Sample /proc/stat twice with a short sleep to get a delta.
    cmd = "cat /proc/stat"

    # --- First sample ---
    while ((cmd | getline line) > 0) {
        if (line ~ /^cpu[0-9]+/) {
            split(line, f)
            id = f[1]
            idle1[id]  = f[5]
            total1[id] = f[2]+f[3]+f[4]+f[5]+f[6]+f[7]+f[8]
        }
    }
    close(cmd)

    system("sleep 0.5")

    # --- Second sample ---
    while ((cmd | getline line) > 0) {
        if (line ~ /^cpu[0-9]+/) {
            split(line, f)
            id = f[1]
            idle2[id]  = f[5]
            total2[id] = f[2]+f[3]+f[4]+f[5]+f[6]+f[7]+f[8]
            cores[id]  = 1
        }
    }
    close(cmd)

    # Block chars: index 0 (idle/very-low) → 7 (100 %)
    blocks[0] = "▁"
    blocks[1] = "▂"
    blocks[2] = "▃"
    blocks[3] = "▄"
    blocks[4] = "▅"
    blocks[5] = "▆"
    blocks[6] = "▇"
    blocks[7] = "█"

    graph = ""
    # Sort core keys numerically
    n = asorti(cores, sorted, "@ind_str_asc")
    for (i = 1; i <= n; i++) {
        id = sorted[i]
        dtotal = total2[id] - total1[id]
        didle  = idle2[id]  - idle1[id]
        pct = (dtotal > 0) ? (dtotal - didle) * 100 / dtotal : 0

        # Choose block character (0–7)
        idx = int(pct / 12.5)
        if (idx > 7) idx = 7
        if (idx < 0) idx = 0
        blk = blocks[idx]

        # Colour
        if (pct >= 80)
            colour = "#[fg=red]"
        else if (pct >= 50)
            colour = "#[fg=yellow]"
        else
            colour = "#[fg=green]"

        graph = graph colour blk
    }

    printf graph "#[fg=default]"
}
'
