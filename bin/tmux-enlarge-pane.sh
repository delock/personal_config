#!/bin/bash
WINDOW_HEIGHT=`tmux display -p '#{window_height}'`
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

if [ $RESIZE_HEIGHT -lt $PANE_HEIGHT ]
then
    RESIZE_HEIGHT=$PANE_HEIGHT
fi

tmux resize-pane -y $RESIZE_HEIGHT

