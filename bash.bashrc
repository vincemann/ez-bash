# System-wide .bashrc file for interactive bash(1) shells.

# To enable the settings / commands in this file for login shells as well,
# this file has to be sourced in /etc/profile.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, overwrite the one in /etc/profile)
# but only if not SUDOing and have SUDO_PS1 set; then assume smart user.
if ! [ -n "${SUDO_USER}" -a -n "${SUDO_PS1}" ]; then
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

# Commented out, don't overwrite xterm -T "title" -n "icontitle" by default.
# If this is an xterm set the title to user@host:dir
#case "$TERM" in
#xterm*|rxvt*)
#    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
#    ;;
#*)
#    ;;
#esac

# enable bash completion in interactive shells
#if ! shopt -oq posix; then
#  if [ -f /usr/share/bash-completion/bash_completion ]; then
#    . /usr/share/bash-completion/bash_completion
#  elif [ -f /etc/bash_completion ]; then
#    . /etc/bash_completion
#  fi
#fi

# if the command-not-found package is installed, use it
if [ -x /usr/lib/command-not-found -o -x /usr/share/command-not-found/command-not-found ]; then
	function command_not_found_handle {
	        # check because c-n-f could've been removed in the meantime
                if [ -x /usr/lib/command-not-found ]; then
		   /usr/lib/command-not-found -- "$1"
                   return $?
                elif [ -x /usr/share/command-not-found/command-not-found ]; then
		   /usr/share/command-not-found/command-not-found -- "$1"
                   return $?
		else
		   printf "%s: command not found\n" "$1" >&2
		   return 127
		fi
	}
fi

# THIS PC ONLY
alias ?='helpCommands'
alias explorer='i3-msg exec dolphin `pwd`'
# find aliases
alias fpd='source findProjectDir'
alias fd='source findDir'
alias fdoc='findDoc'
alias fdocd='source findDocDir'
alias f='findGlobal'
alias fed='sudo $(whereis findAndEdit | cut -d " " -f2-)'

#my env_vars
export PATH=/usr/local/bin/personal:$PATH
export PATH=/home/vince/programme/mitm:$PATH
export PATH=/usr/local/bin/public:$PATH
export PATH=/home/vince/.config/i3/bin:$PATH
export PATH=/home/vince/projekte/important/vote-snack-backend/scripts:$PATH
export CPV_SCREEN=eDP-1
export CPV_DOC_DIR=/home/vince/dokumente
# graphene os installation
export PATH="/home/vince/Downloads/platform-tools:$PATH"
export SUDO_ASKPASS=/usr/bin/ssh-askpass


##############################################################################################################################################################################################################################
# COPY THIS TO EVERY PC I WORK WITH

# CHANGE THESE IF NEEDED vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

export DIR_HISTORY="/home/vince/.dir-history"
export HISTFILE=/home/vince/.bash_eternal_history
export HIST_AMOUNT_LOGIN=4

# CHANGE THESE IF NEEDED ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

# DEPENDENCIES:_________________________________________________
# xclip
# screen
# trash-cli

# put into local bashrc:
# HISTSIZE=
# HISTFILESIZE=
# ______________________________________________________________


# Eternal bash history.
# ---------------------
# Undocumented feature which sets the size to "unlimited".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTSIZE=
export HISTFILESIZE=
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login

# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"



# CD HISTORY 					by vincemann @ https://github.com/vincemann/cd-history

# extends functionality of cd:
# saves last visited directories systemwide and let user cd into recently visited dirs
# aliases cd with bashfunction providing additional features

# USAGE
# cd -- 	// display recent history with indexes
# cd -- foo	// display recent history results containing word foo
# cd - 3 	// cd into dir from histoty at index 3
# cd --- 	// display whole history

#____________________________________________________________________________________________

cd_func ()
 {
    local x2 newDir adir index dir_hist
    local -i cnt

    # GET HISTOY FILE
    dir_hist=`echo $DIR_HISTORY`
    if [ -z "$dir_hist" ]
    then
      dir_hist="~/.dir-history"
    fi
    # create history stack if not already there
    if [[ ! -e "$dir_hist" ]]; then
        touch "$dir_hist"
    fi

    # LIST LAST DIRS
    if [[ $1 ==  "--" ]]; then
	# if arg after -- is present, it is interpreted as must-match-word in path
	matchWord="$2"
	if [ -n "$matchWord" ];
	then
		cat -n "$dir_hist" | grep -i "$matchWord" | head -11
	else
		cat -n "$dir_hist" | head -11
	fi
     	return 0
    fi

    # LIST ALL DIRS
    if [[ $1 ==  "---" ]]; then
	cat -n "$dir_hist" | more
     return 0
    fi
	
	
     newDir=$1
     [[ -z $1 ]] && newDir=$HOME

     # extract dir by index and update dir, that gets cd into -> newDir
     if [[ ${newDir:0:1} == '-' ]]; then
       index=$2
     [[ -z $index ]] && index=1
	adir=`sed "${index}q;d" "$dir_hist"`
       [[ -z $adir ]] && return 1
       newDir=$adir
     fi

     # CONVERT TO ABS
     newDir=`readlink -f "$newDir"`
     command cd "$newDir"
     # if cd failed, return 1 and dont save invalid dir on stack
     [[ $? -ne 0 ]] && return 1
     
     # save dir on stack
     tmp=`mktemp`
     echo "$newDir" | cat - "$dir_hist" > "$tmp"
     cat "$tmp" > "$dir_hist"
     rm -f "$tmp"
     
     # remove duplicate dirs
     tmp2=`mktemp`
     awk '!visited[$0]++' "$dir_hist" > "$tmp2"
     cat "$tmp2" > "$dir_hist"
     rm -f "$tmp2"

     chmod a+rw "$dir_hist"
     return 0
   }

   alias cd=cd_func

   if [[ $BASH_VERSION > "2.05a" ]]; then
     # ctrl+w shows the menu
     bind -x "\"\C-w\":cd_func -- ;"
   fi


#____________________________________________________________________________________________

path_func()
{
	file="$1"
	abs_path=$(readlink -n -f "$file")
	echo -n "$abs_path" | copy_func
	log "$abs_path"
	return 0
}

where_func()
{
	file="$1"
	path=$(whereis "$file"| cut -d " " -f 2)
	echo -n "$path" | copy_func
	log "$path"
	return 0
}

popup()
{
	# maybe later add new line support:
	# https://unix.stackexchange.com/questions/231089/how-to-move-forward-in-a-line-in-bash-with-echo
	msg="$1"
	time="$2"
	if [[ -z "$time" ]];then
		time="1000"
	fi
	notify-send "$msg" -t "$time"
	return $?
}


# merge config of subl user & root
edit_func()
{
	# turn command into string
	file="$1"
	cmd_format="subl %s"
	printf -v cmd "$cmd_format" "$file"	
	if test -f "$file"; then
		# file does exist
		log "editing file"
		repeat_with_sudo_if_not_writeable "$file" "$cmd"
	else
		# file does not exist
		log "creating file"
		dir="$file"
		if [[ "$file" == *"/"* ]]; then
  			# is path
  			dir=$(dirname "$file")
  		else
  			dir=$(pwd)
		fi
		repeat_with_sudo_if_not_writeable "$dir" "$cmd"
	fi
	return $?
}

resolve_alias()
{
	echo "${BASH_ALIASES[$1]}"
}

log()
{
	msg="$1"
	echo "$msg"
	# echo "$msg" >> "/tmp/gil.bash.log"
}

loge()
{
	>$2 log "$@"
}

chmodx_func()
{
	file="$1"
	cmd="chmod a+x %s"
	printf -v res_cmd "$cmd" "$file"	
	if test -f "$file"; then
		# file does exist
		repeat_with_sudo_if_not_writeable "$file" "$res_cmd"
		return 0
	else
		loge "file does not exist"
		return 1
	fi
}

# USE WITH CAUTION
repeat_with_sudo_if_not_writeable()
{
	file="$1"
	cmd="$2"
#	log "command :$cmd"
	test -w "$file"
	local status=$?
	if (( status != 0 ));then
		log "root"
		sudo $cmd
		return $?
	else
		log "normal user"
		$cmd
		return $?
	fi

}

# USE WITH CAUTION
reapeat_with_sudo_on_fail()
{
	cmd="$1"
	# try execute command with normal rights
	$cmd
	ret=$?
	if (( status != 0 ));then
		log "repeating as root"
		# replace with sudo func? What if cmd contains bash functions?
		# should already use alias though
		sudo $cmd
	fi
	return $ret
}

# cuts off last newline if present
copy_func()
{
	silent xclip -rmlastnl -selection clipboard
	ret=$?
	popup "copied"
	return $ret
}


copyn_func()
{
	silent xclip -selection clipboard
	ret=$?
	popup "copied"
	return $?
}

# cuts off last newline
paste_func()
{
	to_paste=$(xclip -rmlastnl -selection clipboard -o)
	ret=$?
	echo -n "$to_paste"
	return $ret
}


pasten_func()
{
	to_paste=$(xclip -selection clipboard -o)
	ret=$?
	echo -n "$to_paste"
	return $ret
}

# see man trash*
# rm file 		-> puts file to trash
# rm -ff file 		-> deletes file fully
rm_func()
{
	force="$1"
	if [[ "$force" == "-ff" ]];then
		log "forced remove"
		shift 1
		# echo "args: $@"
		rm -rf "$@"
		return $?
	fi
	log "move to trash"
	trash "$@"
	return $?
}

silent_func()
{
	$@ 1>&2>/dev/null
	return $?
}



# makes sudo work with bashfunctions and aliases
sudo_func()
{
	out=$(mktemp)
	err=$(mktemp)
	# maybe need to replace all " with \"
	cmd=$(echo -en "${@} 1>\"$out\" 2>\"$err\"")
	# echo 'command: '"$cmd"''
	sudo bash -i -c ''"$cmd"'' 1>&2>/dev/null
	# bash inherits exit code from subshell
	ret=$?
	out=$(cat "$out")
	err=$(cat "$err")
	if [[ -n "$out" ]];then
		echo "$out"
	fi
	if [[ -n "$err" ]];then
		>$2 echo "$err"
	fi
	return ret
}


# Aliases
alias rm=rm_func
# run in background, if term down, process still runnning
# works with x so guis will open
alias back='screen -dm -s'
# alias backx='screen -dm'
alias grep='grep --color=auto'
alias path=path_func
alias where=where_func
alias mark='ack --passthru'
alias copy=copy_func
# copy without newline
alias copyn=copyn_func
alias paste=paste_func
alias pasten=pasten_func
# needs to be done so aliases and bashfunctions work with sudo
alias sudo=sudo_func
alias e=edit_func
alias x=chmodx_func
alias size='sudo du -sh'
alias silent=silent_func

alias c='cd -'
alias cc='cd --'

# show last sessions dir and move to last dir
cd -- | head -n $HIST_AMOUNT_LOGIN
cd - 1



# https://unix.stackexchange.com/questions/119/colors-in-man-pages
# Get color support for 'less' thus also in manpages
export LESS="--RAW-CONTROL-CHARS"
[[ -f ~/.LESS_TERMCAP ]] && . ~/.LESS_TERMCAP


##############################################################################################################################################################################################################################
