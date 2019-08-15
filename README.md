## Container Name ##
sas-adxr-cedar

## Developers ##
Chris Johnson <chris.johnson@sas.com>
Tom Georgoulias <tom.georgoulias@sas.com>

## Code Location ##
https://gitlab.sas.com/infra-dev/vanguard-control-loops/tree/master/cedar

## Inter-dependent services ##
* Access to docker command

## Log Location ##
Logs from this service go to stdout.

## Access instructions ##
N/A

## Included health monitors ##
No health monitors are included at this time.

## Functional accounts used ##
This service uses a Vanguard API account capable of modifying deployments
ADX Account: cedar-controller

## Upgrade Process ##
Standard k8s container update process.

## Process to scale component ##
Scaling is not supported for this service.

## Process to deploy component ##
##   ?   ## 
https://gitlab.sas.com/infra-dev/vanguard-control-loops/raw/master/config/kubernetes/cedar-ctl.yml

## List of functions/tasks performed ##
* Retreive the current POAC version 
* Test connectivity to harbor and docker repos
* Retrieve updated repos if applicable 

## Steps to complete tasks manually ##
* Retreive the current POAC version
* Test connectivity to harbor and docker repos
* Retrieve updated repos if applicable

