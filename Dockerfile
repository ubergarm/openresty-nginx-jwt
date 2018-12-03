FROM openresty/openresty:alpine-fat

RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-jwt

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;", "-c", "/etc/nginx/nginx.conf"]
