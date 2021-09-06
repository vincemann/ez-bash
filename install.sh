#!/bin/bash
sudo apt install -y xclip
sudo apt install -y screen
sudo apt install -y trash-cli
sudo apt install -y ack

if [[ -n "$1" ]];then
	echo "installing sublime editor"
	wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
	echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
	sudo apt install apt-transport-https
	sudo apt update
	sudo apt install sublime-text
else
	echo "not installing sublime"
fi

start_pattern="# EZ BASH START"
end_pattern="# EZ BASH END"
bashrc="/etc/bash.bashrc"

# backup
sudo cp "$bashrc" "$HOME/.ez-bash-system-bashrc.bak"

# replace vars
template_file=$(mktemp)
cat bashrc-template > "$template_file"

sed -i -e "s@§HOME@$HOME@g" "$template_file"



replace_or_add_paragraph()
{
	file="$1"
	start_pattern="$2"
	end_pattern="$3"
	data_file="$4"

	start_found=$(sudo cat "$file" | grep --count "$start_pattern")
	end_found=$(sudo cat "$file" | grep --count "$end_pattern")

	if [[ "$start_found" -eq 1 && "$end_found" -eq 1 ]];then
		echo "found prev installation, updating..."
		# remove old version
		sudo sed -i "/$start_pattern/,/$end_pattern/d" "$file"
		# install new
		cat "$data_file" | sudo tee -a "$file" 1>/dev/null
	elif [[ "$start_found" -eq 0 && "$end_found" -eq 0 ]];then
		cat "$data_file" | sudo tee -a "$file" 1>/dev/null
	else
		echo "invalid amount of installations found: start: $start_found, end: $end_found"
		exit 1
	fi
}

replace_or_add_line()
{
	file="$1"
	pattern="$2"
	line="$3"

	found=$(sudo cat "$file" | grep --count "$pattern")

	if [[ "$found" -eq 1 ]];then
		sed -i "s/.*$pattern.*/$line/g" "$file"
	elif [[ "$found" -eq 0 ]];then
		echo "$pattern" | sudo tee -a "$file"
	else
		echo "pattern found multiple times, skip replacement"
	fi
}

replace_or_add_paragraph "$bashrc" "$start_pattern" "$end_pattern" "$template_file"

# eternal history needs to be set locally as well
replace_or_add_line "$HOME/.bashrc" "HISTSIZE=" "export HISTSIZE="
replace_or_add_line "$HOME/.bashrc" "HISTFILESIZE=" "export HISTFILESIZE="
replace_or_add_line "$HOME/.bashrc" "HISTCONTROL=" "export HISTCONTROL=ignoreboth"

echo "installed"
echo "restart terminal for changes to take effect"