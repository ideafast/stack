#!/bin/sh
rm -rf docs
git clone git@github.com:ideafast/ideafast-devicesupportdocs-web.git docs
/bin/bash ./jekyll-build.sh
docker-compose restart