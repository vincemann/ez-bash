#!/bin/bash



INSTALLING_USER=$SUDO_USER


sudo apt install -y xclip
sudo apt install -y screen
sudo apt install -y trash-cli
sudo apt install -y ack
sudo apt install -y git



GUI=$1
LOCAL=$2

# always execute as your user not with sudo or root
print_usage()
{
	echo "(ez-bash) usage ./install gui|terminal local|system [extensions...]"
	echo "possible extensions: cd-history, file-history, ssh-edit"
	exit 1
}


if [[ $GUI = "gui" ]]; then
	echo "installing gui version"

	# https://github.com/st4s1k/gsudo - i want to display gui sudo prompt when executing sudo in gui env
	echo "install dependency gsudo from github"
	mkdir -p /tmp/gsudo
	git clone git@github.com:st4s1k/gsudo.git /tmp/gsudo/
	chmod +x /tmp/gsudo/gsudo_installer
	bash /tmp/gsudo/gsudo_installer
	rm -rf /tmp/gsudo
	echo "done with installing gsudo"

elif [[ $GUI = "terminal" ]]; then
	echo "installing terminal version"
else
	print_usage
fi


if [[ $LOCAL = "local" ]];then
	echo "installing locally for user "
elif [[ $LOCAL = "system" ]];then
	echo "installing system wide"
else
	print_usage
fi

install_github_extension()
{	

	install_dir="/opt/ezbash/"
	sudo mkdir -p "$install_dir"
	sudo chown -R "${USER}:${USER}" "$install_dir"
	repo=$1
	old_dir=$(pwd)
	command cd "$install_dir"
	git clone "https://github.com/vincemann/"$repo".git"
	command cd "./$repo"
	echo "args for installation: ${@:2}"
	./install.sh "${@:2}"
	command cd "$old_dir"
}

install_extensions()
{
	for (( i=1; i<=$#; i++)); do
    	extension="${!i}"
    	echo "installing extension: $extension"
    	if [[ "$extension" = "cd-history" ]]; then
			install_github_extension "$extension" $GUI $LOCAL
		elif [[ "$extension" = "file-history" ]]; then
			install_github_extension "$extension" $GUI
		elif [[ "$extension" = "ssh-edit" ]]; then
			install_github_extension "$extension"
		else
			print_usage
		fi
		echo "successfully installed extension: $extension"
	done

}



start_pattern="# EZ BASH START"
end_pattern="# EZ BASH END"

bashrc="/etc/bash.bashrc"
bash_functions_dir="/etc/bash-functions"
if [[ "$LOCAL" = "local" ]]; then
	bashrc="$HOME/.bashrc"
	bash_functions_dir="$HOME/bash-functions"
fi

bash_functions_file_path="$bash_functions_dir/ez-bash-functions"

# backup
mkdir -p "$HOME/.ezbash-suite-backups"
sudo cp "$bashrc" "$HOME/.ezbash-suite-backups/.ez-bash-bashrc.bak"

# replace vars
template_file=$(mktemp)
cat bashrc-template > "$template_file"

sed -i -e "s@§HOME@$HOME@g" "$template_file"


# add/replace bash functions file and add bash functions dir if needed
rm -f "$bash_functions_file_path"
sudo mkdir -p "$bash_functions_dir"
sudo chown -R "${USER}:${USER}" "$bash_functions_dir"
cp ez-bash-functions "$bash_functions_file_path"


sudo bash ./lib/replace_or_add_paragraph.sh "$bashrc" "$start_pattern" "$end_pattern" "$template_file"

# eternal history needs to be set locally as well
./lib/replace_or_add_line.sh "$HOME/.bashrc" "HISTSIZE=" "export HISTSIZE="
./lib/replace_or_add_line.sh "$HOME/.bashrc" "HISTFILESIZE=" "export HISTFILESIZE="
./lib/replace_or_add_line.sh "$HOME/.bashrc" "HISTCONTROL=" "export HISTCONTROL=ignoreboth"
# not needed bc I dont source functions, I define them twice
# ./lib/replace_or_add_line.sh "$HOME/.bashrc" "EZ_BASH_FUNCTIONS_DIR=$bash_functions_dir


install_extensions ${@:3}

echo "installed"
echo "restart terminal for changes to take effect"
