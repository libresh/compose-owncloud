# ownCloud
ownCloud app for IndieHosters network!

## Prerequisite

You need to have [docker](https://docs.docker.com/linux/started/) and [docker-compose](http://docs.docker.com/compose/) installed.

## How to run ownCloud

Modify `docker-compose.yml` `ROOT_URL` and `MYSQL_ROOT_PASSWORD`value to match your environment.

And then:

```bash
./RUN
```

And all the data will be located under the `./data` folder.

## TLS

```
mkdir cert
cd cert
openssl dhparam 2048 -out dhparam.pem
cp your.key cert/private.key
cp your.cert cert/domain.crt
cp root.cert cert/root.crt
chmod 600 cert/private.key
```

## Memcached

Add this to your conf file:

```
  'memcache.local' => '\OC\Memcache\Memcached',
  'memcached_servers' => array(
        array('memcached', 11211),
),
```

And make sure to rebuild locally the image to have memcached support in php:
```
docker build -t indiehosters/owncloud
```

## How to Backup this

Just run:

```bash
./BACKUP
```

This will create a dump of the mysql database. Then just copy the data folder to a safe location and you should be fine!

## Question?

If you have any questions, don't hesitate to open issues.


