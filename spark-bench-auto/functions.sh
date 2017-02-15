function check_package(
    echo "Checking if $1 is installed"
    dpkg -s $1 > /dev/null
  if [ $? -eq 0 ]; then
		echo "$1 already installed"
	else
		echo "Installing $1"
		echo "sudo apt install $1"
		sudo apt install $1
	fi
}
