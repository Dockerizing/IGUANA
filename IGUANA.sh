#!/bin/bash

# Init the volumes
########################

CONFIG="$PWD/config.xml"
QUERIES="$PWD/queries.txt"
RESULTS=$PWD/results

# End of init-volumes
########################

# Init some vars
IMAGE="aksw/dld-present-iguana"
_docker="/usr/bin/docker"
_zenity="/usr/bin/zenity"
DARG=""

# Do some startup checks
#clear
echo "# IGUANA Setup #"
command -v ${_docker} >/dev/null 2>&1 || { 
	echo >&2 "Please install Docker (http://docker.com/) first!"
	if [ ! -t 1 ] ; then 
		${_zenity} --error --text="Please install Docker (http://docker.com/) first!"
	fi	
	echo "(Press any key to exit...)"
	read -rn1
	exit 1
}

# Check if our image is present
if ! ${_docker} images | grep aksw/dld-present-iguana ; then
	echo "[INFO] Docker-Image $IMAGE does not exist locally. We pull it first:"
	#if [ ! -t 1 ] ; then 
	#	${_zenity} --notification --text="Docker-Image $IMAGE does not exist locally. We pull it first."
	#fi
	${_docker} pull $IMAGE
fi

if [ -f $CONFIG ]; then
	DARG+=" -v $CONFIG:/iguana/config_test.xml"
else
	echo "[INFO] No config file given"
fi

if [ -f $QUERIES ]; then
	DARG+=" -v $QUERIES:/iguana/queries.txt"

else
	echo "[INFO] No queries file given"
fi

if [ -d $RESULTS ]; then
	DARG+=" -v $RESULTS:/iguana/results"

else
	echo "[INFO] No results dir given"
fi

# Add our image to docker run
DARG+=" $IMAGE:latest"

# Run 
echo "# Run Docker-Image $IMAGE:"
${_docker} run $DARG

# Done ;)
if [ ! -t 1 ] ; then 
	${_zenity} --info --text="Done.\nCheck your results in ${RESULTS}"
fi
echo "(Press any key to exit...)"
read -rn1