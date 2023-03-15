#!/bin/bash
#
# Script for using fzf in TMUX to access cheat.sh contents easily

# Default location of sacrifice script (change as needed)
THESACRIFICE="~/.tmux/scripts/cheat/thesacrifice"

# Define some languages and commands
languages=`echo "bash golang lua python php ruby" | tr ' ' '\n'`
commands=`echo "split tar cut tmux awk zip unzip sed find ps lvm yum apt" | tr ' ' '\n'`

# Used for entering raw input or if looking for default help screen from cheat.sh
direct=`echo "RAW HELP" | tr ' ' '\n'`

# Drive it all into fzf
selected=`printf "$languages\n$commands\n$direct" | sort | fzf`

# Postprocessing fun
postproc() {
    # This assumes you are using copy-mode-vi keybinds, goal here is minimal keystrokes
    # Rebind q so it will kill the window from within copy mode
    tmux bind -T copy-mode-vi q run-shell "tmux kill-window -t CHT"
    # Rebind y so it will yank selection and kill window from within copy mode
    tmux bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard; tmux kill-window'
    # Sleep to ensure cht.sh data renders into new window
    sleep 1
    # Go into copy-mode
    tmux copy-mode
    # Jump to start of buffer
    tmux send-keys 'gg'
    # This is fugly, but it works... create a sacraficial session that we will use to trigger restoration of normal
    # copy-mode-vi key binds, this cleans itself up after the CHT window is closed in tmux
    tmux new-session -d -s sacrifice
    tmux neww -d -t sacrifice: '${THESACRIFICE}; tmux wait -S thesacrifice'
}

# Check if we're looking for a language
if echo $languages | grep -qs $selected ; then
    read -p "CHT.sh Query of language ${selected} (blank for summary): " query
    # If nothing is provided just get <language>/:learn from cht.sh, otherwise fire in the query data
    if [ -v $query ]; then
        tmux neww -n 'CHT' bash -c "curl 'cht.sh/$selected/:learn' & while [ : ] ; do sleep 1 ; done"
    else
        tmux neww -n 'CHT' bash -c "curl cht.sh/$selected/`echo $query | tr ' ' '+'` & while [ : ] ; do sleep 1 ; done"
    fi
# Otherwise check if we're looking at a command
elif echo $commands | grep -qs $selected ; then
    read -p "CHT.sh Query of command ${selected}: " query
    if [ -v $query ] ; then
        tmux neww -n 'CHT' bash -c "curl cht.sh/$selected & while [ : ] ; do sleep 1 ; done"
    else
        tmux neww -n 'CHT' bash -c "curl cht.sh/$selected~$query & while [ : ] ; do sleep 1 ; done"
    fi
    postproc
# If all else fails this is either going to be a RAW query or a standard HELP query
else
    if [ $selected == "HELP" ] ; then
        tmux neww -n 'CHT' bash -c "curl cht.sh/:help & while [ : ] ; do sleep 1 ; done"
    else
        read -p "CHT.sh raw query: " query
        tmux neww -n 'CHT' bash -c "curl cht.sh/$query & while [ : ] ; do sleep 1 ; done"
    fi
    postproc
fi

