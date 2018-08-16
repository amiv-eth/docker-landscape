# First stage: fetch static landscape files
FROM ubuntu:18.04 as build

ENV DEBIAN_FRONTEND=noninteractive

# Add repository that contains the landscape server
RUN apt-get update && \
    apt-get -fy install software-properties-common && \
    add-apt-repository ppa:landscape/18.03
RUN apt-get update && \
    apt-get -fy install landscape-server

# Second stage: make final image
FROM alpine:latest

WORKDIR /var/www/landscape

RUN apk add --no-cache bash apache2 apache2-proxy apache2-utils

# copy files from first stage
COPY --from=build /opt/canonical/landscape/canonical/landscape .
#COPY --from=build /opt/canonical/landscape/canonical/static ./static
COPY --from=build /opt/canonical/landscape/apacheroot ./config

RUN for module in rewrite proxy_http slotmem_shm ssl headers expires; do sed -i '/LoadModule '"$module"'_module/s/^#//g' /etc/apache2/httpd.conf; done
#RUN for module in rewrite proxy_http ssl headers expires; do a2enmod $module; done

COPY assets/apache.conf /etc/apache2/conf.d/landscape.conf

COPY assets/proxy-entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh
RUN mkdir /run/apache2

CMD ["/sbin/entrypoint.sh"]
