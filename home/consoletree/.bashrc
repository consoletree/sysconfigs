#
# ~/.bashrc
#

#echo "Setup own email server"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1="\\[\e[0;32m\\]\W>\\[\e[m\\] "

web() { curl -s $1 | html2text | less ;}
ytmp3() { link=$(/misc/scripts/ytfzf -L $*) && youtube-dl -x --audio-format mp3 --audio-quality 0 -o ~/Music/"%(title)s.%(ext)s" $link ;}

function via() { find . | fzf --reverse --height=40% -m --border=rounded --prompt="$ " --marker="+" | xargs -r -I \% $* \% ;}
function goto() { cd $(find . -maxdepth 30 -type d | fzf --reverse --height=40% -m --border=rounded --prompt="$ " --marker="+") ;}

set -o vi
#pulseaudio --start

alias ls="ls --color=auto"
alias grep="grep --color=auto"
alias diff="diff --color=auto"
alias pacman="pacman --color=always"
alias cp="cp -p -i"
alias rm="rm -i"
alias mv="mv -i"

alias india="TZ=Asia/Kolkata date"
alias matt="qemu-system-x86_64 -enable-kvm -cdrom TempleOS.ISO -boot menu=on -drive file=temp.img -m 2G -cpu host"
alias man="MANPAGER=less man"
alias logout="loginctl terminate-user $USER"
alias suspend="loginctl suspend"
alias simple='export PS1="> "'
alias recscr="ffmpeg -f x11grab -i :0.0 $1"
alias recgif="ffmpeg -f x11grab -framerate 10 -video_size 800x600 -i :0.0+0,30 -r 1 -t 5 $1"
alias reccam="ffmpeg -i /dev/video0 $1"
alias recaud="arecord -f cd -d 10 --device=\"hw:0,0\" $1"
alias ytdlpl='youtube-dl --ignore-errors --format bestaudio --extract-audio --audio-format mp3 --audio-quality 160K --output '\''%(title)s.%(ext)s'\'' --yes-playlist'
alias sudo='doas'
alias rtv='tuir'
alias hx="history | fzf | cut -d' ' -f 5- | xclip -selection c"
alias me="mpv /dev/video0 --profile=low-latency --untimed"

xhost +si:localuser:root >> /dev/null
setxkbmap -option "ctrl:nocaps"

export PATH=$PATH:/misc/appimages/
export PATH=$PATH:/misc/scripts/

export READER="zathura"
