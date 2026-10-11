FROM hersheltheodorelayton/hhvm-full:beta

WORKDIR /mnt/project

COPY . .
COPY .hhconfig /etc/hh.conf
CMD composer update && \
    vendor/bin/pha-linters-server.sh -s -g -e
