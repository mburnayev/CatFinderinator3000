#!/bin/bash

if [ $# -eq 0 ] || [ $# -gt 1 ]
  then
    echo "No arguments passed in, script requires one argument, pass in 'help' for possible args"
    exit
fi

if [ $1 = "help" ]
    then
        echo "----- setup.sh Help -----"
        echo "Input forms:"
        echo "- [sudo] ./setup.sh help"
        echo "- [sudo] ./setup.sh all"
        echo "- [sudo] ./setup.sh <stage number>"
        echo ""
        echo "Input details:"
        echo "- help: outputs this menu again"
        echo "- all: sequentially executes all 3 stages listed below"
        echo "- <stage number>: executes just 1 of the 3 following stages:"
        echo "  - 1: Setup Raspberry Pi"
        echo "  - 2: Setup Download and Install Python 3.9.2"
        echo "  - 3: Setup Python Virtual Environment"
        echo "----- setup.sh Help -----"
        exit
fi

if [ $1 -eq 1 ] || [ $1 = "all" ]
    then
        echo "---------- Executing stage 1 ----------"
        echo "---------- Running apt-get update... ----------"
        sudo apt-get update
        echo "---------- apt-get update done ----------"

        echo "---------- Setting up static IP... ----------"
        sudo apt-get install vim -y
        iface=`ip r | awk '{print $3}' | sed -n 2p`
        router_IP=`ip r | awk '{print $3}' | sed -n 1p`
        DNS_IP=`grep "nameserver" /etc/resolv.conf | awk '{print $2}'`
        desired_IP=`cat static_ip.txt`

        touch /etc/dhcpcd.conf
        echo "interface $iface" > /etc/dhcpcd.conf
        echo "static_routers=$router_IP" >> /etc/dhcpcd.conf
        echo "static domain_name_servers=$DNS_IP" >> /etc/dhcpcd.conf
        echo "static ip_address=$desired_IP/24" >> /etc/dhcpcd.conf

        cat /etc/dhcpcd.conf
        echo "---------- Done setting up static IP ----------"
        echo "---------- Stage 1 Setup Complete ----------"
fi

if [ $1 -eq 2 ] || [ $1 = "all" ]
    then 
        echo "---------- Executing stage 2 ----------"
        echo "---------- Setting up Python 3.9.2... ----------"
        sudo apt-get install -y build-essential tk-dev libncurses5-dev libncursesw5-dev libreadline6-dev libdb5.3-dev libgdbm-dev libsqlite3-dev libssl-dev libbz2-dev libexpat1-dev liblzma-dev zlib1g-dev libffi-dev
        wget https://www.python.org/ftp/python/3.9.2/Python-3.9.2.tar.xz
        tar xf Python-3.9.2.tar.xz
        cd Python-3.9.2
        ./configure --enable-optimizations --prefix=/usr
        make
        sudo make altinstall

        cd ..
        sudo rm -r Python-3.9.2
        rm Python-3.9.2.tar.xz
        . ~/.bashrc

        sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.9 1
        py_ver=`python -V`
        echo "Python version is: $py_ver"
        echo "alias python=/usr/bin/python3.9" >> ~/.bashrc
        . ~/.bashrc
        echo "---------- Finished setting up Python 3.9.2 ----------"
        echo "---------- Stage 2 Setup Complete ----------"
fi

if [ $1 -eq 3 ] || [ $1 = "all" ]
    then
        echo "---------- Executing stage 3 ----------"
        echo "---------- Setting up Python Virtual Environment... ----------"
        cd /home/pi/Downloads/project
        python -m venv ppvenv
        # TODO: add command that sets `include-system-site-packages = true` in <venv>/pyvenv.cfg
        source ppvenv/bin/activate
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        echo "---------- Finished setting up Python Virtual Environment ----------"
        echo "---------- Stage 3 Setup Complete ----------"
fi

# script can then be run using `python3 main.py`