#!/bin/bash
# byobu useful keybindings:
# shift-F11 - toggle zoom
# shift-F9  - send command to all panes
# shift-F12 - disable/enable keybindings
# alt-F12   - disable/enable mouse
# shift-F2  - split pane horizontally
# ctrl-F2   - split pane vertically
# shift-F5  - toggle splits arrangement

# to copy and paste, shift-F12 to disable mouse then highlight and copy

# tmux useful keybindings:
# cat >> .tmux.conf << EOF
# socket_path=~/.tmux_socket/default
##setw -g mode-keys vi
## shortcut for synchronize-panes toggle
## START:sync
#bind M-s set -g synchronize-panes
## END:sync
#EOF


# split tmux window to number of hosts listed in a file and ssh to them

while getopts ":f:n:" cmd_args; do 
  case $cmd_args in
     n ) number_of_hosts=$OPTARG
       ;;
     f ) hosts_file=$OPTARG
       ;;
    \? ) echo "Invalid option: $OPTARG" 1>&2
       ;;
     : ) echo "Invalid option: $OPTARG requires an argument" 1>&2
       ;; 
  esac
  shift $((OPTIND -1))
done

echo $hosts_file
[ -z "$hosts_file" ] && echo "file contain host(s) is require...ie '-f hosts.txt'" && exit 1

hosts_count=$(cat $hosts_file |wc -l)
set -- `cat $hosts_file`
byobu-tmux -S ~/.tmux_socket/$hosts_file new-session -s "mySession" -d
while [ $# -gt 1 ]
do
     byobu-tmux -S ~/.tmux_socket/$hosts_file attach -t:0 \; split-window -v \; detach
     byobu-tmux -S ~/.tmux_socket/$hosts_file select-layout tiled
     shift
done
set -- `cat $hosts_file`
while [ $# -ge 1 ]
do
     byobu-tmux -S ~/.tmux_socket/$hosts_file send-keys -t $(($# - 1)) "ssh ubuntu@$1 $cmd" Enter
     shift
done
byobu-tmux -S ~/.tmux_socket/$hosts_file attach
