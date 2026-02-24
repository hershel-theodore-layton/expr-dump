FROM hersheltheodorelayton/hhvm-full:beta

WORKDIR /mnt/project

COPY . .
COPY .hhconfig /etc/hh.conf
CMD composer update && \
    vendor/bin/pha-linters-server.sh -i -s -g -b ./vendor/hershel-theodore-layton/portable-hack-ast-linters-server/bin/portable-hack-ast-linters-server-bundled.resource
