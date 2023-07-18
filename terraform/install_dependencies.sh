#!/bin/bash
set -e

function install_kernel_modules() {
  sudo apt update -y
  sudo apt install make -y
  sudo apt install gcc -y
  git clone https://github.com/free5gc/gtp5g.git && cd gtp5g
  make clean && make
  sudo make install
}

function install_docker() {
    sudo apt-get update -y
    sudo apt-get install ca-certificates curl gnupg -y
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
}

function clone_free5gc_repo_and_start_containers() {
    git clone https://github.com/free5gc/free5gc-compose.git
    cd free5gc-compose

    cd base
    git clone --recursive -j `nproc` https://github.com/free5gc/free5gc.git
    cd ..

    sudo make all
    sudo docker compose up -d
}

function deploy_monitoring() {
    cd /
    git clone https://github.com/aman-2812/free5gc-monitoring.git
    cd free5gc-monitoring/monitoring/
    sudo docker compose up -d
}

install_kernel_modules
install_docker
clone_free5gc_repo_and_start_containers
deploy_monitoring