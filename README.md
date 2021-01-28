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
This service uses a Vanguard API account capable of modifying deployments
ADX Account: cedar-controller

## Upgrade Process ##
Standard k8s container update process.

## Process to scale component ##
Scaling is not supported for this service.

## Process to deploy component ##
Deployed using the std kubectl diff methods located at:
https://gitlab.sas.com/adx/ac-cluster/-/tree/master/k8s/sas-adxr-system/09-cedar


## List of functions/tasks performed ##
* Retreive the current POAC version 
* Retrieve updated repos if applicable 

## Steps to complete tasks manually ##
* Retreive the current POAC version
* Retrieve updated repos if applicable

