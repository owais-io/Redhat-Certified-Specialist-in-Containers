FROM alpine:latest
RUN apk add --no-cache nginx && adduser -D nginxuser && chown -R nginxuser:nginxuser /var/lib/nginx

USER nginxuser

#--------------------------------------------------------
# FROM alpine:latest
# RUN apk add --no-cache nginx && rm -rf /var/cache/apk/*

#--------------------------------------------------------
# FROM nginx:latest
# RUN rm -rf /var/cache/apt/* /var/lib/apt/lists/*
