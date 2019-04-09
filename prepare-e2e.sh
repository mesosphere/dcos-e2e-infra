#!/bin/bash

set -eo pipefail

VARIANT=${1-}
if [[ ${VARIANT} != 'open' && ${VARIANT} != 'ee' ]] ; then
    echo 'No valid variant set, falling back to open'
    VARIANT=open
fi

# Install prerequisites
sudo apt-get update
sudo apt-get -y install git gcc make zlib1g-dev libffi-dev libssl-dev \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common

# Install Docker
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER

if [[ ${VARIANT} == "ee" ]] ; then
    # Clone dcos-enterprise
    mv id_rsa ~/.ssh
    git clone git@github.com:mesosphere/dcos-enterprise.git
    DCOS_DIR=dcos-enterprise
    rm ~/.ssh/id_rsa
    curl -o ~/dcos_generate_config.sh https://downloads.mesosphere.com/dcos-enterprise/testing/master/dcos_generate_config.ee.sh
else
    git clone https://github.com/dcos/dcos.git
    DCOS_DIR=dcos
    curl -o ~/dcos_generate_config.sh https://downloads.dcos.io/dcos/testing/master/dcos_generate_config.sh
fi

# Prepare Python environment
curl https://pyenv.run | bash
echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
echo 'pyenv global 3.7.3' >> ~/.bashrc

export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

pyenv install 3.7.3
pyenv global 3.7.3

# Prepare e2e tests
cd ${DCOS_DIR}/test-e2e
pip install -r requirements.txt

echo 'export DCOS_LICENSE=${cat ~/e2e/license.txt}' >> ~/.bashrc
echo 'export DCOS_E2E_TMP_DIR_PATH=/tmp' >> ~/.bashrc
echo 'export DCOS_E2E_GENCONF_PATH=~/dcos_generate_config.sh' >> ~/.bashrc
echo 'export DCOS_E2E_LOG_DIR=/tmp/logs' >> ~/.bashrc

