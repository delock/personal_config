echo RAM=`
cat /proc/meminfo|awk '
/MemAvailable/ {
    ava = $2;
}
/MemTotal/ {
    tot = $2;
}
END{
    print int((tot-ava)/(1024*1024)*100)/100 "/" int(tot/(1024*1024)*100)/100 "G"
}'
`
