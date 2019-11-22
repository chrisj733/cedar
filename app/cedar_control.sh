#!/bin/bash

#Create the SymLinks and configuration directory for docker.  The symlink will be created from our transported harbor-creds (see the deployment yaml)

mkdir /root/.docker
ln -s /etc/secret/.dockerconfigjson /root/.docker/config.json

daytimer=0

while true
do


# Step 1, retreive the manifests in use.  This has changed quite a bit, but this seems to be the best way for now:

mapfile -t image_array1 < <(kubectl get rs --all-namespaces -o yaml | grep 'harbor.unx.sas.com' | grep -oP '(?<=image: ).*' )
mapfile -t image_array2 < <(kubectl get rs --all-namespaces -o yaml | grep 'docker.sas.com' | grep -oP '(?<=image: ).*' )
mapfile -t image_array3 < <(kubectl get deployment --all-namespaces -o yaml | grep 'harbor.unx.sas.com' | grep -oP '(?<=image: ).*' )

image_array=( "${image_array1[@]}" "${image_array2[@]}" "${image_array3[@]}" )

# Step 2, sort this highly redundant array

sorted_image_array=($(echo "${image_array[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

# Now we have our target array, we can go to work.

echo Printing Current Image List:
echo ${sorted_image_array[@]}

# test for repo availability before we try and pull anything down
/usr/bin/curl --silent --connect-timeout 3 https://registry.unx.sas.com > /dev/null
if [ $? -eq 0 ]; then
  echo 'Repo registry.unx.sas.com is available'
  REGISTRY_REACH=TRUE
else
  echo 'unable to connect to registry.unx.sas.com'
  REGISTRY_REACH=FALSE
fi

/usr/bin/curl --silent --connect-timeout 3 https://harbor.unx.sas.com > /dev/null
if [ $? -eq 0 ]; then
  echo 'Repo harbor.unx.sas.com is available'
  HARBOR_REACH=TRUE
else
  echo 'unable to connect to harbor.unx.sas.com'
  HARBOR_REACH=FALSE
fi


# Step 3, if the repos are up, let's go out and do our fetching fetch.  After 20 runs we'll do a system prune.

if [ $REGISTRY_REACH -a $HARBOR_REACH ]; 
 then
   echo 'Repos are Available, Beginning Control Loop'
   echo 'Attempting Docker Pull from: harbor.unx.sas.com'
   for i in ${sorted_image_array[@]}
   do
    echo "Attempting Pull from $i"
    docker pull $i 
   done
  
   echo 'Sleeping a few seconds'
   sleep 3600
   echo "Total Daily Run Time = $daytimer"
   daytimer+=1 
   # Increment day timer until a day is reached.  Then, do a deep system prune
   if (daytimer -ge 20); then
      echo "RunTimer has reached $daytimer, beginning system prune"
      docker system prune --filter "until=72h" --filter=label=maintainer="PDT <pdt@wnt.sas.com>"
      echo "Prune Complete, resetting..."
      daytimer=0
   fi
fi

done
