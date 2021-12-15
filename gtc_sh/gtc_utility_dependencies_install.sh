#!/bin/bash
#
# Usage:
#  gtc_dependencies_install.sh
#   
# Arguments & Options:
#   -h                 : Help option displays usage
#   
# Examples:
#   $ gtc_dependencies_install.sh
#   
# Debug Script:
#   
# 
#Installe jq
function gtc_dependency_jq_install() {
    jq -V &>/dev/null || {
        echo "GoToCloud: Installing jq ..."
        sudo yum -y install jq
        #echo "GoToCloud: Done"
        }
}

#Installe pcluster
function gtc_dependency_pcluster_install() {
    echo "GoToCloud: Installing parallelcluster ..."
    pcluster version &>/dev/null && {
        PV=$(pcluster version | jq -r '.version')
        echo "GoToCloud: Parallelcluster "${PV}" is already installed."
        #echo "GoToCloud: Done"
    } || {
        pip3 install "aws-parallelcluster" --upgrade --user
        echo "GoToCloud: "
        echo "GoToCloud: Check PATH settings for parallelcluster"
        echo "GoToCloud: which pcluster "
        which pcluster
        echo "GoToCloud: "
        PV=$(pcluster version | jq -r '.version')
        echo "GoToCloud: Parallelcluster "${PV}" is installed."
        #echo "GoToCloud: Done"
    }
}

#Installe Node.js
function gtc_dependency_node_install() {
    echo "GoToCloud: Installing Node.js ..."
    source ~/.nvm/nvm.sh && {
        nvm use --lts &>/dev/null
    } && {
        GTC_NODE_VERSION=$(node --version)
        echo "GoToCloud: Node.js version "${GTC_NODE_VERSION}" is already installed"
        #echo "GoToCloud: Done"
    } || {
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
        chmod 755 ~/.nvm/nvm.sh
        source ~/.nvm/nvm.sh
        GTC_NODE_VERSION_BF=$(node --version)  #nvm install node  #install latest version
        nvm install --lts  #install lts version
        nvm alias default 'lts/*'  #set lts version to default
        nvm uninstall ${GTC_NODE_VERSION_BF}
        GTC_NODE_VERSION=$(node --version)
        echo "GoToCloud: Node.js "${GTC_NODE_VERSION}" is installed"
        #echo "GoToCloud: Done"
    }
}