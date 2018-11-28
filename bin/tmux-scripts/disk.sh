df -h|awk '
/\/data\/media/ {
    print "~=" $4
}
/\/mnt\/media_rw\// {
    print "#=" $4
}
'
