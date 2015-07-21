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

## How to Backup this

Just run:

```bash
./BACKUP
```

This will create a dump of the mysql database. Then just copy the data folder to a safe location and you should be fine!

## Question?

If you have any questions, don't hesitate to open issues.


