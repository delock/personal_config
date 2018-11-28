WINDOW_WIDTH=`tmux display -p '#{window_width}'`
SCRIPT_PATH=`dirname $0`
if [ $WINDOW_WIDTH \> 100 ];
then
echo `$SCRIPT_PATH/tmux-scripts/cpu.sh`\
 `$SCRIPT_PATH/tmux-scripts/mem.sh`\
#[fg=colour8]\|#[fg=]`$SCRIPT_PATH/tmux-scripts/disk.sh`\
#[fg=colour8]\|#[fg=]`$SCRIPT_PATH/tmux-scripts/battery.sh`\
#[fg=colour8]\|#[fg=]`$SCRIPT_PATH/tmux-scripts/time.sh`
else
echo `$SCRIPT_PATH/tmux-scripts/cpu.sh`\
 `$SCRIPT_PATH/tmux-scripts/mem.sh`\
#[fg=colour8]\|#[fg=]`$SCRIPT_PATH/tmux-scripts/time.sh`
fi;
