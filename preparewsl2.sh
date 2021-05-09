export DEBIAN_FRONTEND=noninteractive
sudo -E apt-get -y update
sudo -E apt-get -y upgrade
mkdir -p ~/.local/bin
source ~/.profile

# Essential tools
sudo -E apt-get install -y unzip git figlet jq screenfetch
sudo -E apt-get install -y apt-transport-https ca-certificates curl software-properties-common
sudo -E apt-get install -y python3 python3-pip build-essential libssl-dev libffi-dev python-dev  


# Install Docker Compose into your user's home directory.
pip3 install --user docker-compose


# Tell GPG what kind of terminal this is
echo 'export GPG_TTY=$(tty)' >> ~/.bashrc


# SSH directory 
mkdir -p ~/.ssh/
chmod 700 ~/.ssh