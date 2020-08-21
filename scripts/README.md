# Deploy HelloSpa
---
The script builds a docker image of HelloSpa and deploys it into Vagrant Centos/7 box.

## Content
---
The script contains following files:
* Vagrantfile
* Dockerfile
* .dockerignore
* scripts folder
  * main.sh - script responsible for whole deployment process
  * prov.sh - Vagrant provision script
  * funcs.sh - functions used in main.sh and prov.sh
  * READM.md - this file

## Running the script
---
1. Change permissions on main.sh to allow execution
2. Execute main.sh as sudo, e.g. 
   `sudo ./main.sh [docker_login] [image_name]`
  * `docker_login` - user's login on DockerHub
  * `image_name` - name of new image
  * `-h or --help` - displays main usage information
3. During running of script user will be asked to provide password to DockerHub
4. The application should be available directly from host on:
	[http://localhost:4224](http://localhost:4224)

