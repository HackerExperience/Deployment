#!/bin/bash
set -e

cd $(dirname $0)
git init
git remote add origin https://github.com/renatomassaro/jenkins-docker.git
git fetch
git checkout -t origin/master

cd -
docker build -t jenkins $(dirname $0)

