#!/bin/bash
sudo apt install -y xclip
sudo apt install -y screen
sudo apt install -y trash-cli
sudo apt install -y ack

start_pattern="# EZ BASH START"
end_pattern="# EZ BASH END"
start_found=$(sudo cat /etc/bash.bashrc | grep --count "$start_pattern")
end_found=$(sudo cat /etc/bash.bashrc | grep --count "$end_pattern")
bashrc="/etc/bash.bashrc"

# backup
sudo cp "$bashrc" "./system-bashrc.bak"

# replace vars
template=$(mktemp)
cat bashrc-template > "$template"
sed -i "s/§HOME/$HOME" "$template"


if [[ "$start_found" == "1" && "end_found" == "1" ]];then
	echo "found prev installation, updating..."
	# remove old version
	sudo sed -i "/$start_pattern/,/$end_pattern/d" "$bashrc"
	# install new
	cat "$template" | sudo tee -a "$bashrc"
elif [[ "$start_found" == "0" && "end_found" == "0" ]];then
	cat "$template" | sudo tee -a "$bashrc"
else
	echo "invalid amount of ez-bash installations found: $start_found"
	exit 1
fi


# eternal history needs to be set locally as well
sed -i "s/HISTSIZE=.*/HISTSIZE=/g" "$HOME/.bashrc"
sed -i "s/HISTFILESIZE=.*/HISTFILESIZE=/g" "$HOME/.bashrc"