ps -eo pcpu,args|awk '
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
}'
