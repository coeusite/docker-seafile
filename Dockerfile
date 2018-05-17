FROM debian:stretch

# Initially was based on work of Alessandro Viganò, Andreas Löffler <andy@x86dev.com> and xama <oliver@xama.us>
MAINTAINER CoeusITE <coeusite@posteo.org>

# Base system
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && apt-get upgrade -y && \
    apt-get install -y ca-certificates nginx net-tools wget curl supervisor apt-utils procps nano && \
    apt-get install -y \
        libreoffice libreoffice-script-provider-python poppler-utils \
        ttf-wqy-microhei ttf-wqy-zenhei xfonts-wqy \
        openjdk-8-jre poppler-utils libpython2.7 python-pip \
        python-setuptools python-imaging python-mysqldb python-memcache python-ldap python-urllib3 python-boto python-requests && \
    apt-get clean all && \
    sed -i 's/^\(\[supervisord\]\)$/\1\nnodaemon=true/' /etc/supervisor/supervisord.conf

# ENV
ENV SEAFILE_VERSION 6.2.12

# Seafile
RUN mkdir /opt/seafile/logs -p && \
    cd /opt/seafile/ && \
    wget "https://download.seafile.com/d/6e5297246c/files/?p=/pro/seafile-pro-server_${SEAFILE_VERSION}_x86-64.tar.gz&dl=1" -O "seafile-pro-server_${SEAFILE_VERSION}_x86-64.tar.gz" && \
    tar xzf seafile-pro-server_* && \
    mkdir installed -p && \
    mv seafile-pro-server_* installed

# Nginx
ADD config/seafile-nginx.conf /etc/nginx/sites-available/seafile
# Supervisor
ADD config/seafile-supervisord.conf /etc/supervisor/conf.d/seafile-supervisord.conf
# bootstrap
ADD script/bootstrap-data.sh /usr/local/sbin/bootstrap
# bootstrap-nginx
ADD script/bootstrap-nginx.sh /usr/local/sbin/bootstrap-nginx


# Expose needed ports.
EXPOSE 80

# Volumes
VOLUME ["/etc/nginx", "/opt/seafile", "/etc/supervisor/conf.d"]

# CMD
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
