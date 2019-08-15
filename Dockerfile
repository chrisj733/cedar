FROM alpine

RUN apk --no-cache add bash curl docker
RUN mkdir -p /app
ADD app /app
RUN chmod 755 /app/start.sh
RUN chmod 755 /app/cedar_control.sh

ENTRYPOINT /app/start.sh
