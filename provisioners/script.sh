#!/bin/bash

USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)

export DEBIAN_FRONTEND=noninteractive

echo "Provisioning virtual machine..."

echo "Updating apt-get..."
#sudo apt-get update -y

if [ ! -d "$USER_HOME/bin" ]; then
  echo "Making bin dir in $USER_HOME..."
  mkdir -p "$USER_HOME/bin"
  chmod a+x $USER_HOME/bin
  echo '
    if [ -d "$HOME/bin" ];
      then PATH="$PATH:$HOME/bin"
    fi' >> $USER_HOME/.bashrc
fi

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
