#!/bin/bash
WINDOW_HEIGHT=`tmux display -p '#{window_height}'`
tmux resize-pane -y $((WINDOW_HEIGHT*8/10))
