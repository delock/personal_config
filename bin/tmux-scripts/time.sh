TZ='Asia/Shanghai' date +"%a WW%W %H:%M:%S - %s = %Y/%m/%d"|awk '
// {
    str=$0;
    sec=$4;
    sub(/-.*=/, "", str);
    if (sec%2==1) {
        sub(/:/, ":", str);
    } else {
        sub(/:/, ":", str);
    }
    print str;
}
'
