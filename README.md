# Canonical Landscape on Docker

The provided images allows you to run an instance of Canonical Landscape with docker.

## Usage

Every container needs the same configuration file (see `example.conf`) mounted on `/landscape.conf`.
They need also a common volume mounted on `/var/lib/landscape`.

You need at least one proxy container and the following service container:

* APPSERVER
* ASYNC_FRONTEND
* JOBHANDLER
* MSGSERVER
* PINGSERVER
* APISERVER
* PACKAGEUPLOADSERVER
* PACKAGESEARCH
* CRON
* *UPGRADE**

Specify the service to run with the environment variable `SERVICE`.

**This service runs the schema updates on the database in case landscape has been updated.*

## Development

The following steps need to be done to upgrade to a newer version:

1. blab
2. blub
3. blob
