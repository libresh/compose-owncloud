# ownCloud
ownCloud app for IndieHosters network!

# How to use this image

The easiest is to use our `docker-compose.yml`.

Make sure you have [docker-compose](http://docs.docker.com/compose/install/) installed. And then if you are not using [LibrePaas](https://github.com/indiehosters/LibrePaaS), set mail and url variables:

```
export URL="YOUR_URL"
export MAIL_DOMAIN="YOUR_MAIL_DOMAIN"
export MAIL_HOST="YOU_MAIL_HOST"
export MAIL_PORT="MAIL_PORT"
export MAIL_PASS="MAIL_PASS"
git clone https://github.com/indiehosters/owncloud.git
cd owncloud
docker-compose up
```

Once it is done, you can open your browser and connect to the IP of the container: http://container_ip.

If you want to access it via the IP of the HOST, add this line to `docker-compose.yml`:
```
web:
...
  ports:
    - "80:80"
...
```

You can now access your instance on the port 80 of the IP of your machine.

## Accees it from Internet

We recommend the usage of TLS, so the easiest is to use the `nginx-tls.conf` file.

```
mkdir cert
cd cert
openssl dhparam 2048 -out dhparam.pem
cp your.key cert/private.key
cp your.cert cert/domain.crt
cp root.cert cert/root.crt
chmod 600 cert/private.key
```

Once it is done, you can connect to the port of the host by adding this line to `docker-compose.yml`:
```
web:
...
  ports:
    - "443:443"
    - "80:80"
...
```

## Installation

Once started, you'll arrive at the configuration wizzard.

## Backup

In order to backup, just run the `./BACKUP` script. And copy all the data to a safe place.
