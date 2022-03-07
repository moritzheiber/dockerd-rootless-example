#!/bin/bash

set -Eeu -o pipefail

USER_NAME="test"
HOME_DIR="/home/${USER_NAME}"

# Add our user which is able to run Docker commands
id "${USER_NAME}" || sudo useradd -m --home-dir ${HOME_DIR} -s /bin/bash -U -G sudo ${USER_NAME}

if [ "$(which curl)x" == "x" ] || \
  [ "$(which wget)x" == "x" ] || \
  [ "$(which gpg)x" == "x" ] || \
  [ "$(which lsb_release)x" == "x" ]; then
  sudo apt update -qq && apt install -y curl wget gpg-agent lsb-release
  install -m0700 -o root -g root -d /root/.gnupg
fi

# Installing the Docker repository for Ubuntu
if ! [ -f /etc/apt/sources.list.d/docker.list ] ; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  sudo sh -c "echo \"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" > /etc/apt/sources.list.d/docker.list"
  sudo apt-get update -qq
fi

# Installing Docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io uidmap

# Disabling the global Docker daemon
# TODO: Could also leave it enabled and set the context based on use-cases?
sudo systemctl disable --now docker.service docker.socket

# We need to enable lingering for the user so that the Docker daemon stays "active" even when the user has no session
sudo loginctl enable-linger ${USER_NAME}

# Setting up Docker-specific settings for the socket and environment
if ! $(sudo -u "${USER_NAME}" test -f "${HOME_DIR}/.config/docker/service_environment") ; then
  sudo -u "${USER_NAME}" mkdir -p "${HOME_DIR}/.config/docker"
  sudo -u "${USER_NAME}" sh -c "echo 'export XDG_RUNTIME_DIR=\"/run/user/$(id -u ${USER_NAME})\"' >> ~/.profile"
  sudo -u "${USER_NAME}" sh -c "echo \"XDG_RUNTIME_DIR=/run/user/$(id -u ${USER_NAME})\" >> \"${HOME_DIR}/.config/docker/service_environment\""
  sudo -u "${USER_NAME}" sh -c "echo 'export DOCKER_HOST=\"unix://\${XDG_RUNTIME_DIR}/docker.sock\"' >> ~/.profile"
  sudo -u "${USER_NAME}" sh -c "echo \"DOCKER_HOST=unix:///run/user/$(id -u ${USER_NAME})/docker.sock\" >> \"${HOME_DIR}/.config/docker/service_environment\""
fi

# Install and enable the user-defined Docker daemon via systemd
sudo -u "${USER_NAME}" mkdir -p "${HOME_DIR}/.config/systemd/user"
sudo -u "${USER_NAME}" install -m0644 -o ${USER_NAME} -g ${USER_NAME} /vagrant/systemd-unit-docker-rootless.service ${HOME_DIR}/.config/systemd/user/docker.service
sudo -iu "${USER_NAME}" systemctl --user daemon-reload
sudo -iu "${USER_NAME}" systemctl --user enable docker.service
sudo -iu "${USER_NAME}" systemctl --user start docker
