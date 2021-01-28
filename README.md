## Container Name ##
sas-adxr-cedar

## Developers ##
Chris Johnson <chris.johnson@sas.com>
Tom Georgoulias <tom.georgoulias@sas.com>

## Code Location ##
https://gitlab.sas.com/adx/cedar

## Inter-dependent services ##
* Access to docker command

## Log Location ##
Logs from this service go to stdout.

## Access instructions ##
N/A

## Included health monitors ##
No health monitors are included at this time.

## Functional accounts used ##

## Upgrade Process ##
Standard k8s container update process.

## Process to scale component ##
Scaling is not supported for this service.

## Process to deploy component ##
##   ?   ## 
https://gitlab.sas.com/adx/cedar/cedar-deploy.yaml

## List of functions/tasks performed ##
* Retreive the current image versions
* Sort image list and dedup
* Test connectivity to harbor and docker repos
* Retrieve updated repos if applicable 

## Steps to complete tasks manually ##
* Retreive the current POAC version
* Test connectivity to harbor and docker repos
* Retrieve updated repos if applicable

