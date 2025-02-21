FROM ubuntu:focal
MAINTAINER iconik Media AB <info@iconik.io>

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y ffmpeg imagemagick poppler-utils ghostscript dcraw exiftool locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
RUN apt-get update && apt-get install -y wget gnupg && \
    wget -O - https://packages.iconik.io/deb/ubuntu/dists/jammy/iconik_package_repos_pub.asc | apt-key add - && \
    echo "deb [trusted=yes] https://packages.iconik.io/deb/ubuntu ./jammy main" > /etc/apt/sources.list.d/iconik.list && \
    apt-get update && \
    apt-get install -y iconik-storage-gateway
VOLUME /var/iconik/iconik_storage_gateway/data

RUN wget https://downloads.red.com/software/rcx/linux/beta/55.1.52132/REDline_Build_55.1.52100_Installer.sh && \
    chmod +x REDline_Build_55.1.52100_Installer.sh && \
    ./REDline_Build_55.1.52100_Installer.sh

COPY ./redline /usr/local/bin/redline

CMD /opt/iconik/iconik_storage_gateway/iconik_storage_gateway \
    --iconik-url=${ICONIK_URL:-https://app-lb.iconik.io/} \
    --auth-token=${AUTH_TOKEN} \
    --app-id=${APP_ID} \
    --storage-id=${STORAGE_ID}
