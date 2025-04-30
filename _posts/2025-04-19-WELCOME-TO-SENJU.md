---
layout: post
title:  "Welcome to Senju!"
---

# Hello and welcome to my personal blog where I will post whatever comes to my mind!

In this first post, I want to show you how to get up and running with the webframework jekyll taht I used for this site.

First, lets go over all things docker!

Here is the Dockerfile I use to get a jekyll builder. 

```Dockerfile
syntax=docker/dockerfile:1
FROM docker.io/ruby:3.4
WORKDIR /app

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 4000
```

The entrypont.sh:

```bash
#!/bin/bash
set -e

git config --global --add safe.directory /app
rm -f /app/tmp/pids/server.pid
gem update --system
bundle install

# Then exec the container's main process (what's set as CMD in the Dockerfile or
# as command in the docker-compose.yml).
exec "$@"
```

You can then use: ```podman build -t jekyll .``` in the directory of the Dockerfile to get your builder.
brustraus
Before continuing, you need to follow the initialisation instructions of jekyll to get you repo started. The other
stuff wont work if you dont to this!!!!!

https://chirpy.cotes.page/posts/getting-started/

Then you use my build script to build the site:

```bash
#!/bin/bash
#GID=$(id -g)
set -e

rm -rf _site
echo "
JEKYLL_ENV=production bundle exec jekyll build --no-watch
rm -vrf /app/_site/docker* /app/_site/entrypoint.sh
" \
| docker run --rm -iv "$PWD:/app:z" jekyll /bin/bash

docker build -t senju_ctf .
```

If you have a server, this handy script can be used to automatically upload the static site to a webserver. (I use caddy btw.)
```bash
#!/bin/bash
UNIXTIME=$(date +%s)
DEPLOY_TO=webdev@senjuctf.lab
WEBROOT=/srv/senjuCTF # if you unset this, everything will explode
TMP_FILE=$(printf "/tmp/%s_site.tar.gz" "$UNIXTIME")
set -e

echo building website
bash ./build.sh

echo making archive...
tar --zstd -cvf $TMP_FILE
echo uploading archive to $DEPLOY_TO : "$TMP_FILE"
scp $TMP_FILE $DEPLOY_TO:"$TMP_FILE"
echo installing archive in webroot: $WEBROOT
echo "
set -e
mkdir -p $WEBROOT
rm -rvf $WEBROOT/* $WEBROOT/.*
tar --zstd -xvf $TMP_FILE --directory $WEBROOT
rm -vf $TMP_FILE
mv -fv $WEBROOT/_site/* $WEBROOT
rmdir -v $WEBROOT/_site
" \
| sshpass -p “HAHA YOU THOUGH I WOULD LEAK MY PASSWORD HERE BUT NOOOO” ssh $DEPLOY_TO /bin/bash
echo removing local upload file
rm -f $TMP_FILE
```

These scripts must be at the root of your site.
