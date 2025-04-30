FROM caddy:alpine

COPY ./Caddyfile /etc/caddy/

WORKDIR /srv/senjuCTF
COPY ./_site .

EXPOSE 80
EXPOSE 443
