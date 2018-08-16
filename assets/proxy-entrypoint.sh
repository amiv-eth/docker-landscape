#!/bin/bash

#set -e

source /landscape.conf

# Update the config file to include all the relevant pieces
sed -i 's,{{DOMAIN}},'"${DOMAIN}"',g' /etc/apache2/conf.d/landscape.conf

sed -i 's,{{SERVICE_PING}},'"${SERVICE_PING}"',g' /etc/apache2/conf.d/landscape.conf
sed -i 's,{{SERVICE_MESSAGE}},'"${SERVICE_MESSAGE}"',g' /etc/apache2/conf.d/landscape.conf
sed -i 's,{{SERVICE_ASYNC_FRONTEND}},'"${SERVICE_ASYNC_FRONTEND}"',g' /etc/apache2/conf.d/landscape.conf
sed -i 's,{{SERVICE_APP}},'"${SERVICE_APP}"',g' /etc/apache2/conf.d/landscape.conf
sed -i 's,{{SERVICE_API}},'"${SERVICE_API}"',g' /etc/apache2/conf.d/landscape.conf
sed -i 's,{{SERVICE_PACKAGE}},'"${SERVICE_PACKAGE}"',g' /etc/apache2/conf.d/landscape.conf

# start Apache
#exec httpd -DFOREGROUND || :
exec httpd &

tail -f /etc/apache2/conf.d/landscape.conf
