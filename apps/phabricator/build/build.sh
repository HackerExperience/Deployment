#!/bin/bash
set -e

git clone https://github.com/renatomassaro/phabricator.git $(dirname $0)

docker build -t phabricator $(dirname $0)
