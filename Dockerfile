FROM caddy:alpine

WORKDIR /srv/senjuCTF
COPY ./_site .

EXPOSE 80
EXPOSE 443
