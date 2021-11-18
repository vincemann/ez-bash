#!/bin/bash
sudo apt install -y xclip
sudo apt install -y screen
sudo apt install -y trash-cli
sudo apt install -y ack
sudo apt install -y git

GUI=$1
LOCAL=$2

print_usage()
{
	echo "usage ./install gui|terminal local|system [extensions...]"
	echo "possible extensions: sublime, cd-history, last-file-history, ssh-file-edit"
	exit 1
}


if [[ $GUI = "gui" ]]; then
	echo "installing gui version"
elif [[ $GUI = "terminal" ]]; then
	echo "installing terminal version"
else
	print_usage
fi


if [[ $LOCAL = "local" ]];then
	echo "installing locally"
elif [[ $LOCAL = "system" ]];then
	echo "installing system wide"
else
	print_usage
fi

install_github_extension()
{	
	repo=$1
	git clone "https://github.com/vincemann/"$repo".git"
	cd $repo
	echo "args for installation: ${@:2}"
	./install.sh "${@:2}"
	cd ..
}

install_extensions()
{
	for (( i=1; i<=$#; i++)); do
    	extension="${!i}"
    	echo "installing extension: $extension"
    	if [[ "$extension" = "sublime" ]]; then
    		if [[ "$GUI" = "terminal" ]]; then
    			echo "WARN: you are installing the terminal version, installing sublime editor might not be very useful"
    		fi
			wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
			echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
			sudo apt install apt-transport-https
			sudo apt update
			sudo apt install sublime-text
			echo "loading keymap config"
			cp subl-config "$HOME/.config/sublime-text-3/Packages/User/Default (Linux).sublime-keymap"
			if [[[ "$LOCAL" = "system" ]]; then
				sudo cp subl-config "/root/.config/sublime-text-3/Packages/User/Default (Linux).sublime-keymap"	
			fi
		elif [[ "$extension" = "cd-history" ]]; then
			install_github_extension "$extension" $GUI $LOCAL
		elif [[ "$extension" = "last-file-history" ]]; then
			install_github_extension "$extension" $GUI $LOCAL
		elif [[ "$extension" = "ssh-edit" ]]; then
			install_github_extension "$extension" $GUI $LOCAL
		else
			print_usage
		fi
		echo "successfully installed extension: $extension"
	done

}


start_pattern="# EZ BASH START"
end_pattern="# EZ BASH END"

bashrc="/etc/bash.bashrc"
if [[[ "$LOCAL" = "local" ]]; then
	bashrc="$HOME/.bashrc"
fi

# backup
mkdir -p "$HOME/.ezbash-suite-backups"
sudo cp "$bashrc" "$HOME/.ezbash-suite-backups/.ez-bash-bashrc.bak"

# replace vars
template_file=$(mktemp)
cat bashrc-template > "$template_file"

sed -i -e "s@§HOME@$HOME@g" "$template_file"



sudo bash ./lib/replace_or_add_paragraph "$bashrc" "$start_pattern" "$end_pattern" "$template_file"

# eternal history needs to be set locally as well
./lib/replace_or_add_line.sh "$HOME/.bashrc" "HISTSIZE=" "export HISTSIZE="
./lib/replace_or_add_line.sh "$HOME/.bashrc" "HISTFILESIZE=" "export HISTFILESIZE="
./lib/replace_or_add_line.sh "$HOME/.bashrc" "HISTCONTROL=" "export HISTCONTROL=ignoreboth"


install_extensions ${@:3}

echo "installed"
echo "restart terminal for changes to take effect"