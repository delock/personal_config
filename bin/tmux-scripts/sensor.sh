sensors -u|awk '
BEGIN {
    temp = 0;
}
/temp.*_input/{
    if (temp <$2) temp = $2;
}
END {
    print " " temp*10/10 "°"
}'
