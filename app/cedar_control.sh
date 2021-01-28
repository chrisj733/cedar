#!/bin/bash

runcount=0

function log {
    echo "$(date -I'seconds') - $*"
}

while true
do

log "Gathering images from manifests"

# Step 1, retreive the manifests in use.  This has changed quite a bit, but this seems to be the best way for now:

mapfile -t image_array1 < <(kubectl get rs --all-namespaces -o yaml | grep 'image:' | grep -v 'cr.sas.com' | grep 'sas.com' | grep 'registry' )
mapfile -t image_array2 < <(kubectl get deployment --all-namespaces -o yaml | grep -v 'cr.sas.com' | grep 'image:' | grep 'sas.com' | grep 'registry' )
mapfile -t image_array3 < <(kubectl get daemonset --all-namespaces -o yaml | grep -v 'cr.sas.com' | grep 'image:' | grep 'sas.com' | grep 'registry' )


image_array=( "${image_array1[@]}" "${image_array2[@]}" "${image_array3[@]}" )

echo $image_array

# Step 2, sort this highly redundant array

sorted_image_array=($(echo "${image_array[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

# Now we have our target array, we can go to work.

log Printing Current Image List:
log ${sorted_image_array[@]}

log 'Attempting Docker Pull from our repos...'
for i in ${sorted_image_array[@]}
do
 log "docker pull $i"
 docker --config /app/.docker/ pull $i 
done
  
log 'Sleeping for one hour'
sleep 3600
runcount+=1 
log "runcount = $runcount"
# Increment day timer until a day is reached.  Then, do a deep system prune
if (runcount -ge 23); then
   log "runcount has reached $runcount, beginning system prune"
   docker --config /app/.docker/ system prune --filter "until=72h" --filter=label=maintainer="PDT <pdt@wnt.sas.com>"
   log "Prune Complete, resetting..."
   runcount=0
fi

done
