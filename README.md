# Canonical Landscape on Docker

The provided images allows you to run an instance of Canonical Landscape with docker.

## Usage

Every container needs the same configuration file (see `example.conf`) mounted on `/landscape.conf`.
They need also common volumes mounted on `/var/lib/landscape` and `/var/lib/landscape-server`.

You need at least one proxy container and the following service container:

* APPSERVER
* ASYNC_FRONTEND
* MSGSERVER
* PINGSERVER
* APISERVER
* PACKAGEUPLOADSERVER
* CRON
* *UPGRADE**

Specify the service to run with the environment variable `SERVICE`.

**This service runs the schema updates on the database in case landscape has been updated.*

## Development

The following steps need to be done to upgrade to a newer version:

1. blab
2. blub
3. blob

## License

Copyright (C) 2018 AMIV an der ETH, Sandro Lutz

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
