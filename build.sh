#!/bin/bash
#GID=$(id -g)
set -e

cd ./jekyll_builder
docker build -t jekyll .

cd ..

rm -rf _site
echo "
JEKYLL_ENV=production bundle exec jekyll build --no-watch
rm -vrf /app/_site/docker* /app/_site/entrypoint.sh
" \
| docker run --rm -iv "$PWD:/app:z" jekyll /bin/bash

docker build -t senju_ctf .
