Docker image for Seafile
--------------------

This Dockerfile installs latest [Seafile](https://www.seafile.com) with HTTPS (TLS) enabled by default.

Idea and initial Dockerfile was based on https://github.com/alvistar/seafile-docker

**Note:** If you want to use a stable version, use coeusite/docker-seafile:phusion instead.

## Features

The image contains/adds the following:

- Latest Seafile (6.0.7)
- Nginx for TLS (HTTPS) support
- Self-signed certificates, generated automatically on first run
- Runit for keeping the services up and running

## Changelog

- 2017/02/13: Switch to debian:jessie with supervisor. Update Seafile Server to version 6.0.7.
- 2016/11/22: Update Seafile Server to version 6.0.6.
- 2016/09/22: Added initial support for Seafile 6.0.4 and using the official MariaDB Docker image. Stay tuned for updates.
- 2015/04/18: Added initial support for Seafile 4.x and using the official mysql Docker image. Stay tuned for updates.

## Architecture

For running Seafile within Docker, three containers are needed, namely:

- **seafile**, which contains the actual Seafile instance running on the server
- **seafile-db**, the MySQL database container
- **seafile-data**, the data container

Having different containers is nice if you need/want to upgrade and/or backup
your installation.

## Quickstart

Create a custom bridge network

```bash
docker network create --subnet=172.172.39.0/24 nginx-proxy
```

Create the MariaDB(()MySQL) database container by running:

```bash
docker volume create --name seafile-dbstore

docker run -d -p 127.0.0.1:3306:3306 \
  --network nginx-proxy --ip 172.172.39.98 \
  -v seafile-dbstore:/var/lib/mysql:rw \
  -e MYSQL_ROOT_PASSWORD=<password> \
  -e MYSQL_DATABASE=seafile \
  -e MYSQL_USER=seafile \
  -e MYSQL_PASSWORD=<password> \
  --name seafile-db mariadb:latest
```
This will create the needed container, based on [mariadb](https://hub.docker.com/r/_/mariadb/). This also assumes that you're
not yet running another database at port 3306 on your host. In case you do, e.g. use
```
-p 127.0.0.1:33306:3306
```
to expose the database' internal port 3306 to localhost:33306 on your host.

As we need the IP of your database container later, look it up by doing a:

```bash
docker inspect "seafile-db" | grep IPAddress | cut -d '"' -f 4
```

It should be _172.172.39.98_ if you are following instructions above.

Note: IPv6 support is **not** implemented in this Dockerfile yet!

Now, create the actual Seafile volume (for storing the actual data), using:

```bash
docker run -it --dns=127.0.0.1 \
  --network nginx-proxy --ip 172.172.39.99 \
  -e SEAFILE_DOMAIN_NAME=<YOUR.HOST.NAME> \
  --name seafile-data coeusite/docker-seafile:latest  bootstrap
```

**Note:** The <yourdomain.tld> should either point to a IP or valid domain you want to run Seafile on. If you're running Docker on
your localhost you simply can specify _127.0.0.1_.

**Bonus:** If you want to specify a different port than _8080_, add the parameter
```
SEAFILE_DOMAIN_PORT=<yourport>
```
to the command line above. Don't forget to change the port at the final command later on though!

The script which now runs will ask a few questions to correctly set up all the things for you, in particular:
```
"What is the name of the server?"
```
Hint: Enter the name (**not** a domain or IP!) of this Seafile installation.

```
"What is the ip or domain of the server?"
```
Hint: If you're running Docker on your local PC, enter **127.0.0.1** -- otherwise enter the IP or
domain of your server you're running Docker on.

```
"What is the host of mysql server?"
```
Hint: Enter the IP of your **seafile-db** container, e.g. 172.172.39.98. Remember the step from above?

**Important:** For all other questions just accept the defaults by pressing _[ENTER]_.

Almost done! Now actually run Seafile using the database and the volume with:

```bash
docker run -d -t --dns=127.0.0.1 -p 127.0.0.1:8080:8080 \
            --network nginx-proxy --ip 172.172.39.99 \
            --volumes-from seafile-data \
            -e SEAFILE_DOMAIN_NAME=<YOUR.HOST.NAME> \
            --name seafile coeusite/docker-seafile
```

Remember to configure your firewall properly, e.g. for firewalld:

```bash
firewall-cmd --add-port=8080/tcp --permanent && firewall-cmd --reload
```

Seafile should now be running on your host at

```
https://<yourhost>:8080
```

Congrats, you're now running Seafile using your self-signed certificate!

## Custom Certificate
You can specify a custom certificate instead of using a self-signed one by following steps:
* Move or copy your cert and key into a folder, e.g. /opt/lets-encrypt;
* Rename them as seafile.crt and seafile.key respectively;
* If you are using lets-encrypt, be aware that the lets-encrypt crt should be chained!
* Mount them by adding ```-v /opt/lets-encrypt:/etc/nginx/certs:ro```, e.g.

```bash
docker run -d -t --dns=127.0.0.1 -p 127.0.0.1:8080:8080 \
            --network nginx-proxy --ip 172.172.39.99 \
            --volumes-from seafile-data \
            -v /opt/lets-encrypt:/etc/nginx/certs:ro \
            -e SEAFILE_DOMAIN_NAME=<YOUR.HOST.NAME> \
            --name seafile coeusite/docker-seafile
```

## Cooperation with [jrcs/letsencrypt-nginx-proxy-companion](https://github.com/jrcs/letsencrypt-nginx-proxy-companion)

docker-seafile can work pretty well with jwilder's nginx-proxy and jrcs's letsencrypt-nginx-proxy-companion.
You may check this page for details (**Chinese ONLY**): https://coeusite.github.io/2016/09/27/Docker-Containers-on-My-Dedibox.html
