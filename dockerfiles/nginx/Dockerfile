FROM nginx:mainline-alpine

RUN apk add --no-cache shadow

RUN groupmod -g 1000 nginx && \
    usermod -u 1000  -g 1000 nginx

WORKDIR /var/www/html
