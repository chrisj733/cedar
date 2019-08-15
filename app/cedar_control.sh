#!/bin/bash

#you can get the poac version from kubectl, but that's unavailable on worker nodes.  Instead, we're going to pull the variable in the config yaml and 
#carry it as an OS variable
#revver=$(kubectl get cm plat-svcs-env -o json -n plat-svcs | grep poac_version | sed 's/"//g'| sed 's/,//g' | awk '{print $2}')

revver=$POAC_VERSION

echo "Retrieving Version:  $revver"

# test for repo availability before we try and pull anything down
/usr/bin/curl --silent --connect-timeout 3 https://docker.sas.com > /dev/null
if [ $? -eq 0 ]; then
  echo 'Repo docker.sas.com is available'
  DOCKER_REACH=TRUE
else
  echo 'unable to connect to docker.sas.com'
  DOCKER_REACH=FALSE
fi

/usr/bin/curl --silent --connect-timeout 3 https://harbor.unx.sas.com > /dev/null
if [ $? -eq 0 ]; then
  echo 'Repo harbor.unx.sas.com is available'
  HARBOR_REACH=TRUE
else
  echo 'unable to connect to harbor.unx.sas.com'
  HARBOR_REACH=FALSE
fi

daytimer=0

#Create the SymLinks and configuration directory for docker.  The symlink will be created from our transported harbor-creds (see the yaml)

mkdir /root/.docker
ln -s /etc/secret/.dockerconfigjson /root/.docker/config.json

#Start a sibling docker instance and sleep 15m before launching again

if [ $DOCKER_REACH -a $HARBOR_REACH ]; 
then
   echo 'Repos are Available, Beginning Control Loop'
fi

while [ $DOCKER_REACH -a $HARBOR_REACH ] ; do
  echo 'Attempting Docker Pull from: Docker.sas.com'
  docker pull docker.sas.com/infra-dev/adx/poac:$revver
  echo 'Attempting Docker Pull from: harbor.unx.sas.com'
  docker pull harbor.unx.sas.com/infra-dev/adx/poac:$revver
  docker pull harbor.unx.sas.com/infra-dev/adx/jupyterlab
  docker pull harbor.unx.sas.com/infra-dev/adx/poac:duke
  echo 'Sleeping 900 seconds'
  sleep 900
  echo "Total Daily Run Time = $daytimer"
  daytimer+=900 
  # Increment day timer until a day is reached.  Then, do a deep system prune
  if (daytimer -ge 86400); then
     echo "Daily Timer has reached $daytimer, beginning system prune"
     docker system prune --filter "until=72h" --filter=label=maintainer="PDT <pdt@wnt.sas.com>"
     echo "Prune Complete, resetting..."
     daytimer=0
  fi
done
