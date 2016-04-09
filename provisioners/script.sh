#!/bin/bash

USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)

export DEBIAN_FRONTEND=noninteractive
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

echo "Provisioning virtual machine..."

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

echo "Installing ack..."
sudo apt-get install ack -y

echo "Installing curl..."
sudo apt-get install curl -y

echo "Installing wget..."
sudo apt-get install wget -y

echo "Installing git..."
sudo apt-get install git -y

echo "Installing vim..."
sudo apt-get install vim -y

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

if [ ! -d "/usr/lib/jvm/" ]; then
  echo "Installing java..."

  curl -L --cookie "oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u65-b17/jdk-7u65-linux-x64.tar.gz -o jdk-7-linux-x64.tar.gz

  tar -xvf jdk-7-linux-x64.tar.gz

  sudo mkdir -p /usr/lib/jvm

  sudo mv ./jdk1.7.* /usr/lib/jvm/

  sudo update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.7.0_65/bin/java" 1
  sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.7.0_65/bin/javac" 1
  sudo update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/lib/jvm/jdk1.7.0_65/bin/javaws" 1

  sudo chmod a+x /usr/bin/java
  sudo chmod a+x /usr/bin/javac
  sudo chmod a+x /usr/bin/javaws
  sudo chown -R root:root /usr/lib/jvm/jdk1.7.0_65

  rm jdk-7-linux-x64.tar.gz
  rm -f equip_base.sh
  rm -f equip_java7_64.sh
fi

if [ ! -f "$USER_HOME/bin/lein" ]; then
  echo "Installing leiningen..."
  wget https://raw.github.com/technomancy/leiningen/stable/bin/lein -O $USER_HOME/bin/lein --progress=bar:force
  chmod a+x $USER_HOME/bin/lein
fi

echo "All done, have fun!"
