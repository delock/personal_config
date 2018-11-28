df -h|awk '
/\/home$/ {
    print "~=" $4
}
/\/$/ {
    print "/=" $4
}
'
