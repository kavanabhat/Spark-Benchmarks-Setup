function check_package(){
    echo $1
    dpkg -s $1
    if [ $? -eq 0 ]; then
		echo "$1 already installed"
	else
		echo "Installing $1"
		echo "sudo apt install $1"
		sudo apt install $1
	fi
}
