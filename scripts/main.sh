#!/bin/bash
# Deploy environment script 

# Pre phase 

# --- Start variables declaration

DOCKER_LOGIN=${DOCKER_LOGIN:="jaykay321"}
APP_NAME=${APP_NAME:="solution"}

# End variables declaration ---

# --- Start function declaration

source funcs.sh

# End function declaration ---


### --- Start main part

function main {

# Check number of input parameters

if [ $# -eq 1 ] && [[ "$1" == "--help" || "$1" == "-h" ]];then
  usage
elif [ $# -gt 2 ];then
  usage
fi

# assign default variables

if [ $# -eq 2 ];then
  DOCKER_LOGIN="$1"
  APP_NAME="$2"  
elif [ $# -eq 1 ];then
  DOCKER_LOGIN="$1"
fi	

IMAGE_NAME="$DOCKER_LOGIN/$APP_NAME"
IMAGE_NAME_TAG="$IMAGE_NAME:v1"

###  Prepare environment

install_ansible
install_vagrant
install_vbox
install_dockerce

# allow masquerade for docker containers
FWD_STATUS=$(systemctl is-active --quiet firewalld ; echo $?)
if [ "$FWD_STATUS" == "0" ];then

  # check if MASQUERADE is on
  MASQ_ON=$(firewall-cmd --zone=public --query-masquerade > \
            /dev/null 2>&1; echo $?)

  if [ "$MASQ_ON" != "0" ];then
    echo "Enabling firewalld masquerade"
    echo "============================="
    firewall-cmd --zone=public --add-masquerade --permanent
    
    echo "Reloading firewalld"
    echo "==================="
    firewall-cmd --reload
  fi

  #firewall-cmd --zone=public --add-port=80/tcp && \
  #firewall-cmd --zone=public --add-port=443/tcp && \
  #firewall-cmd --reload
fi

# Build docker image
echo "Building docker Image"
echo "====================="
docker build -t $IMAGE_NAME ../ 
if [ "$?" != "0" ]; then
  echo "Building image failed. Exiting the script"
  exit 1
fi

# Clean up <none> images
## Find <none> images
NONE_IMG=\
$(docker image ls | \
tr -s " " | \
grep -i '<none>')

## Remove all none images
if [ ! -z "$NONE_IMG" ]; then
  echo -e "Found following <none> images:\n$NONE_IMG"
  echo $NONE_IMG | \
  cut -f3 -d " " | \
  xargs docker image rm > /dev/null && \
  echo "<none> images have been removed."
fi

# Push docker image
echo "Tagging docker image as $IMAGE_NAME_TAG"
echo "======================================="
docker tag "$IMAGE_NAME" "$IMAGE_NAME_TAG" && \

printf "\033c" && \
echo "Please provide DockerHub password." && \
docker login -u "$DOCKER_LOGIN" && \

echo "Pushing the image to user's repository" && \
echo "======================================" && \
docker push "$IMAGE_NAME_TAG" && \

echo "Logging out the Docker user" && \
echo "===========================" && \
docker logout 
if [ "$?" != "0" ];then
  echo "There was a problem during docker push"
  exit 1
fi

# Save information about the image
echo "$IMAGE_NAME_TAG" > img_name.txt

# Run vagrant machine
pushd .. > /dev/null
su $(logname) -c 'vagrant plugin install vagrant-vbguest'
su $(logname) -c 'vagrant up --no-provision'
su $(logname) -c 'vagrant vbguest --do install --no-cleanup'
su $(logname) -c 'vagrant provision'
popd > /dev/null

# Remove image information file
rm img_name.txt

### End main part ---

}

main $@
