FROM debian:stretch

# Initially was based on work of Alessandro Viganò, Andreas Löffler <andy@x86dev.com> and xama <oliver@xama.us>
MAINTAINER CoeusITE <coeusite@gmail.com>

# Base system
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && apt-get upgrade -y && \
    apt-get install -y ca-certificates nginx net-tools wget curl supervisor apt-utils && \
    apt-get install -y \
        openjdk-8-jre poppler-utils libpython2.7 python-pip mysql-server \
        python-setuptools python-imaging python-mysqldb python-memcache python-ldap python-urllib3 python-boto python-requests && \
    apt-get clean all && \
    sed -i 's/^\(\[supervisord\]\)$/\1\nnodaemon=true/' /etc/supervisor/supervisord.conf

# debug
# docker run -dit --rm --name test debian:stretch
# docker exec -it test /bin/bash

# Required packages for pro edition
# sqlite3

# ENV
ENV SEAFILE_VERSION 6.2.12

# Seafile
RUN mkdir /opt/seafile/logs -p && \
    cd /opt/seafile/ && \
    wget "https://download.seafile.com/d/6e5297246c/files/?p=/pro/seafile-pro-server_${SEAFILE_VERSION}_x86-64.tar.gz&dl=1" -O "seafile-pro-server_${SEAFILE_VERSION}_x86-64.tar.gz" && \
    tar xzf seafile-pro-server_* && \
    mkdir installed && \
    mv seafile-pro-server_* installed

# Nginx
ADD config/seafile-nginx.conf /etc/nginx/sites-available/seafile
# Supervisor
ADD config/seafile-supervisord.conf /etc/supervisor/conf.d/seafile-supervisord.conf
# bootstrap
ADD script/bootstrap-data.sh /usr/local/sbin/bootstrap


# Expose needed ports.
EXPOSE 80

# Volumes
VOLUME ["/etc/nginx", "/opt/seafile", "/etc/supervisor/conf.d"]

# CMD
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
