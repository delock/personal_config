# personal_config
This is a set of personal configurations and scripts I used for ease of work and eyes.   It covers terminal color,
tmux, vim, git, and a bunch of scripts for searching and find

## terminal
You need to set terminal color (putty, xfce4-terminal, etc.) according to color.txt, in order to get the effect
intended by color scheme of tmux and vim.   Usually you can find it in configuration/preference of these terminal tools.

## tmux
You must use 'tmux -2' to launch tmux to get full color
Create a symbolic link from personal_config/tmux.conf to ~/.tmux.conf
Tmux config file features:
* Better color
* Status bar show many informations (omnisense)
* change prefix key to ctrl-a
* prefix-a would resize pane height to 80% of window height
* Left click on a pane will ensure the pane has at least 10 lines of heihgt
* Right click on a pane will enlarge that pane height to 50% of line, if not already bigger than that
* Shift-left click on a pane is 75% of window height
* Shift-right click will make the pane as tall as possible


## vim

## scripts

Store personal configuration files
* Set up your terminal color follow 'colors.txt'
* Copy files under 'bin' to your ~/bin directory, if you use otherwise, you need to change tmux.conf accordingly
* It is recommended to create symbolic link for vimrc, tmux.conf and other files, so any new changes can be synched
* The command 'seek' and 'findf' in bin directory are for search purpose:
    * seek <filename>   # find file match file name under current directory
    * findf <string>    # find string in files under current directory, create a files contain find result, and open it with vim.  vim can recognize tags in the file and jump to real location with tag jump command
