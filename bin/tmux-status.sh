WINDOW_WIDTH=`tmux display -p '#{window_width}'`
SCRIPT_PATH=`dirname $0`
if [ $WINDOW_WIDTH \> 200 ];
then
echo `$SCRIPT_PATH/tmux-scripts/cpu.sh`\
 `$SCRIPT_PATH/tmux-scripts/mem.sh`\
 `$SCRIPT_PATH/tmux-scripts/sensor.sh`\
#[fg=colour8]\|#[fg=]`$SCRIPT_PATH/tmux-scripts/gpu.sh`\
#[fg=colour8]\|#[fg=]`$SCRIPT_PATH/tmux-scripts/disk.sh`\
#[fg=colour8]\|#[fg=]`$SCRIPT_PATH/tmux-scripts/time.sh`\
#[fg=colour8]\|#[fg=white]`hostname`
else
echo `$SCRIPT_PATH/tmux-scripts/cpu.sh`\
 `$SCRIPT_PATH/tmux-scripts/mem.sh`\
#[fg=colour8]\|#[fg=]`$SCRIPT_PATH/tmux-scripts/time.sh`\
#[fg=colour8]\|#[fg=white]`hostname`
fi;
