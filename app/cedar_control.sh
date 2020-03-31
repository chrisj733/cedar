#!/bin/bash

#Create the SymLinks and configuration directory for docker.  The symlink will be created from our transported harbor-creds (see the deployment yaml)

mkdir /root/.docker
ln -s /etc/secret/.dockerconfigjson /root/.docker/config.json

daytimer=0

function log {
    echo "$(date -I'seconds') - $*"
}

while true
do

log "Gathering images from manifests"

# Step 1, retreive the manifests in use.  This has changed quite a bit, but this seems to be the best way for now:

mapfile -t image_array1 < <(kubectl get rs --all-namespaces -o yaml | grep 'harbor.unx.sas.com' | grep -oP '(?<=image: ).*' )
mapfile -t image_array2 < <(kubectl get rs --all-namespaces -o yaml | grep 'docker.sas.com' | grep -oP '(?<=image: ).*' )
mapfile -t image_array3 < <(kubectl get deployment --all-namespaces -o yaml | grep 'harbor.unx.sas.com' | grep -oP '(?<=image: ).*' )
mapfile -t image_array4 < <(kubectl get deployment --all-namespaces -o yaml | grep 'registry.unx.sas.com' | grep -oP '(?<=image: ).*' )

image_array=( "${image_array1[@]}" "${image_array2[@]}" "${image_array3[@]}" "${image_array4[@]}" )

# Step 2, sort this highly redundant array

sorted_image_array=($(echo "${image_array[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

# Now we have our target array, we can go to work.

log Printing Current Image List:
log ${sorted_image_array[@]}

# test for repo availability before we try and pull anything down
/usr/bin/curl --silent --connect-timeout 3 https://registry.unx.sas.com > /dev/null
if [ $? -eq 0 ]; then
  log 'Repo registry.unx.sas.com is available'
  REGISTRY_REACH=TRUE
else
  log 'unable to connect to registry.unx.sas.com'
  REGISTRY_REACH=FALSE
fi

/usr/bin/curl --silent --connect-timeout 3 https://harbor.unx.sas.com > /dev/null
if [ $? -eq 0 ]; then
  log 'Repo harbor.unx.sas.com is available'
  HARBOR_REACH=TRUE
else
  log 'unable to connect to harbor.unx.sas.com'
  HARBOR_REACH=FALSE
fi


# Step 3, if the repos are up, let's go out and do our fetching fetch.  After 20 runs we'll do a system prune.

if [ $REGISTRY_REACH -a $HARBOR_REACH ]; 
 then
   log 'Repos are Available, Beginning Control Loop'
   log 'Attempting Docker Pull from: harbor.unx.sas.com'
   for i in ${sorted_image_array[@]}
   do
    log "Attempting Pull from $i"
    docker pull $i 
   done
  
   log 'Sleeping a few seconds'
   sleep 3600
   log "Total Daily Run Time = $daytimer"
   daytimer+=1 
   # Increment day timer until a day is reached.  Then, do a deep system prune
   if (daytimer -ge 20); then
      log "RunTimer has reached $daytimer, beginning system prune"
      docker system prune --filter "until=72h" --filter=label=maintainer="PDT <pdt@wnt.sas.com>"
      log "Prune Complete, resetting..."
      daytimer=0
   fi
fi

done
