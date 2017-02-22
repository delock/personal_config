echo `cat ~/tmp/taotie.log``ps -eo pcpu,args|awk '
// {
    sum=sum+$1;
    if($2!="tmux") {
        maxname=max<$1?substr($0,index($0,$1)+length($1)+1):maxname;
        max=max<$1?$1:max
    }
}
END {
    if(max>=5) {
        sub("^[^ ]*/","",maxname);
        printf "#[fg=blue]" substr(maxname,0,20) "#[fg=]=" max "%%#[fg=colour8]|#[fg=]"
    }
    printf "#[fg=]"
    printf "CPU=" sum "%%"
}'`\
 RAM=`
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
`\
`sensors -u|awk '
BEGIN {
    temp = 0;
}
/temp.*_input/{
    if (temp <$2) temp = $2;
}
END {
    print " " temp*10/10 "°"
}'
`\
#[fg=colour8]\|#[fg=]GPU=`
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
'
`\
#[fg=colour8]\|#[fg=]`
df -h|awk '
/\/home$/ {
    print "~=" $4
}
/\/$/ {
    print "/=" $4
}
'
`\
#[fg=colour8]\|#[fg=]`date +"%a WW%W %H:%M:%S - %s = %Y/%m/%d"|awk '
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
'`\
#[fg=colour8]\|#[fg=white]`hostname`
