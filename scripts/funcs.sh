# Function Definitions

# --- START FUNCTION DEFINITIONS

function usage {
    echo "Usage:  deploy docker_login image_name"
    echo -e "\nSolution to interview project\n"
    echo "Default values:"
    echo -e "\tdocker_login:\n\t\t(default value $DOCKER_LOGIN) user docker login to which image will be pushed."
    echo -e "\timage_name:\n\t\t(default value $APP_NAME) name of docker image."
    echo -e "\n-h, --help                       Print this help.\n"
    exit 1
}

function isInstalled {
  # Checking if application is installed
  local status=$(which $1 > /dev/null 2>&1; echo $?)
  echo $status
}

function install_ansible {
  # Install ansible if it's not available
  ANS_INST=$(isInstalled ansible)
  if [ "$ANS_INST" != "0" ];then
    echo "Installing Ansible"
    yum install -yq epel-release && \
    yum install -yq ansible
    if [ "$?" != "0" ]; then
      echo "Something went wrong"
      exit 1
    fi
  fi
}

function install_vagrant {
# Install vagrant if it's not available
  VAG_INST=$(isInstalled vagrant)
  if [ "$VAG_INST" == "1" ];then
    echo "Installing Ansible"
    yum install -yq https://releases.hashicorp.com/vagrant/2.2.9/vagrant_2.2.9_x86_64.rpm
    if [ "$?" != "0" ];then
      echo "Something went wrong"
    fi
  fi
}

function install_vbox {
# Install VirtualBox if it's not available
  VBOX_INST=$(isINstalled virtualbox)
  if [ "$VBOX_INST" == "1" ];then
    echo "Installing VirtualBox 6.1"
    wget https://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo \
         -P /etc/yum.repos.d/
    yum install -yq binutils kernel-devel kernel-headers \
	    libgomp make patch gcc glibc-headers glibc-devel dkms && \
    yum install -yq "VirtualBox-6.1"
    if [ "$?" != "0" ];then
      echo "Something went wrong"
    fi
  fi
}

function install_dockerce {
# Install docker community edition
  DOCK_INST=$(isInstalled docker)
  if [ "$DOCK_INST" == "1" ];then
    echo "Installing Docker-CE"
    yum install -yq yum-utils && \
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && \
    yum install -yq docker-ce docker-ce-cli containerd.io --nobest && \
    echo "Starting and enabling docker"
    systemctl start docker && \
    systemctl enable docker && \
    # Add current user to docker group
    usermod -aG docker $(logname)
  fi
}

# END FUNCITON DEFINITIONS ---
