#!/bin/bash

docker run -d -v /nginx-data/piwik/:/var/www:rw piwik /bin/true
