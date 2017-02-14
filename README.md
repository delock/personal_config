# personal_config
Store personal configuration files
* You must use 'tmux -2' to launch tmux to get full color
* Set up your terminal color follow 'colors.txt'
* Copy files under 'bin' to your ~/bin directory, if you use otherwise, you need to change tmux.conf accordingly
* It is recommended to create symbolic link for vimrc, tmux.conf and other files, so any new changes can be synched
* The command 'seek' and 'findf' in bin directory are for search purpose:
    * seek <filename>   # find file match file name under current directory
    * findf <string>    # find string in files under current directory, create a files contain find result, and open it with vim.  vim can recognize tags in the file and jump to real location with tag jump command
