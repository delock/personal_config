echo GPU=`
nvidia-smi -q -d TEMPERATURE,MEMORY,UTILIZATION|awk '
BEGIN {
    temp = 0;
    gpu = 0;
    used = 0;
    total = 0;
}
/GPU Current Temp/ {
    if ($5 > temp) temp = $5
}
/Gpu/ {
    gpu = gpu + $3
}
/Used/ {
    used+=$3
}
/Total/ {
    total+=$3
}
END {
    print gpu "%"
    print " MEM=" used "/" total "MB"
    print " " temp "°"
}
'`
