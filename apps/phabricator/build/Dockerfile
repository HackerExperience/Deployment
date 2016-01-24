FROM he_base

RUN apk add --no-cache git

RUN mkdir /phabricator

RUN git clone https://github.com/phacility/libphutil.git /phabricator/libphutil
RUN git clone https://github.com/phacility/arcanist.git /phabricator/arcanist
RUN git clone https://github.com/phacility/phabricator.git /phabricator/phabricator
