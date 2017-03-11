#!/bin/bash
WINDOW_HEIGHT=`tmux display -p '#{window_height}'`
# does not count status line height
WINDOW_HEIGHT=$((WINDOW_HEIGHT-1))
PANE_HEIGHT=`tmux display -p '#{pane_height}'`

if [ "$1" == "" ]
then
    RESIZE_HEIGHT=10
else if [ "$1" == "-l" ]
then
    RESIZE_HEIGHT=$2
else
    RESIZE_HEIGHT=$((WINDOW_HEIGHT*$1/100))
fi
fi

if [ $RESIZE_HEIGHT -gt $PANE_HEIGHT ]
then
    tmux resize-pane -y $RESIZE_HEIGHT
fi


