FROM registry.unx.sas.com/vendor/docker.io/library/alpine:3.11.3 as base

# Bash for Scripting
# Grep to pick up latest experimental inverse regex / perl matching
# curl for API use (if querying harbor API)

RUN apk add --update \
   bash \
   grep\
   curl 

RUN curl -o /bin/kubectl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod 755 /bin/kubectl

RUN apk --no-cache add bash curl docker
RUN mkdir -p /app
ADD app /app
RUN chmod 755 /app/start.sh
RUN chmod 755 /app/cedar_control.sh

ENTRYPOINT app/start.sh
