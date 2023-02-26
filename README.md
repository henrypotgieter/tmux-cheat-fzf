# Tmux Cheat.sh FZF Script

This is my take on implementing a means of easily accessing cheat.sh from
inside tmux, dumping you into a fresh window already in copy mode so you can
highlight any text you want to yank.

The script assumes a few things, that you like using vim-keys in tmux when in
copy mode, that you have y bound to yank selections and that you won't mind
both y and q keys being temporarily remapped while the "CHT" window is open.

It uses a somewhat ugly method to remap the aforementioned keys back to what I
normally have set for y and p keys in copy mode in tmux.

Feel free to adjust any of this as you see fit.

# Installation

```
mkdir ~/.tmux/scripts/
git clone https://github.com/henrypotgieter/tmux-cheat-fzf.git ~/.tmux/scripts/cheat
chmod a+x ~/.tmux/scripts/cheat/*
echo -e '# FZF cht popup\nbind C-c display-popup -E -T "┨ Cheat.SH Lookup ┠" -S "fg=colour46" -h "70%" "~/.tmux/scripts/cheat/cht.sh"' >> ~/.tmux.conf
```

# Instructions

The above installation will write this in to your config for tmux and look for
it to be called with ```prefix CTRL-C```, feel free to adjust this as you see
fit.

If you just go with HELP you will get the standard cht.sh help output.

Raw will let you enter whatever you want to put after cht.sh in the URL.

Update the languages and commands variable values to suit whatever you want to
see in the fzf matching menu.


