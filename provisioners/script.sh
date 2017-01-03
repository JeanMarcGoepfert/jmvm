#!/bin/bash

USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)

export DEBIAN_FRONTEND=noninteractive
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

echo "Provisioning virtual machine..."

echo "Adding java ppa"
sudo add-apt-repository ppa:webupd8team/java

echo "Updating apt-get..."
sudo apt-get update -y

if [ ! -d "$USER_HOME/bin" ]; then
  echo "Making bin dir in $USER_HOME..."
  mkdir -p "$USER_HOME/bin"
  chmod a+x $USER_HOME/bin
  echo '
  if [ -d "$HOME/bin" ];
    then PATH="$PATH:$HOME/bin"
  fi' >> $USER_HOME/.bashrc
fi

source $USER_HOME/.bashrc

echo "Installing ag..."
sudo apt-get install silversearcher-ag -y

echo "Installing curl..."
sudo apt-get install curl -y

echo "Installing wget..."
sudo apt-get install wget -y

echo "Installing git..."
sudo apt-get install git -y

echo "Installing vim..."
sudo apt-get install vim -y


echo "installing java..."
# auto accept oracle license
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get install oracle-java8-installer -y

echo "Installing nginx..."
sudo apt-get install nginx -y

echo "Installing postgres..."
sudo apt-get install postgresql postgresql-contrib -y

check_db_exists () {
  sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw $1
}

if ! check_db_exists develop ; then
  echo "Creating dev db user..."
  sudo -u postgres bash -c "psql -c \"CREATE USER dev_user WITH PASSWORD 'dev_password';\""
  echo "Creating dev db..."
  sudo -u postgres bash -c "psql -c \"
    CREATE DATABASE develop OWNER dev_user ENCODING 'UTF-8' LC_COLLATE 'C' LC_CTYPE 'C' template = template0;
  \""
fi

if ! check_db_exists test ; then
  echo "Creating test db user..."
  sudo -u postgres bash -c "psql -c \"CREATE USER test_user WITH PASSWORD 'test_password';\""
  echo "Creating test db..."
  sudo -u postgres bash -c "psql -c \"
    CREATE DATABASE test OWNER test_user ENCODING 'UTF-8' LC_COLLATE 'C' LC_CTYPE 'C' template = template0;
  \""
  echo "Restarting postgres..."
  sudo service postgresql restart
fi

if [ ! -f "$USER_HOME/bin/lein" ]; then
  echo "Installing leiningen..."
  wget https://raw.github.com/technomancy/leiningen/stable/bin/lein -O $USER_HOME/bin/lein --progress=bar:force
  chmod a+x $USER_HOME/bin/lein
fi

echo "All done, have fun!"
