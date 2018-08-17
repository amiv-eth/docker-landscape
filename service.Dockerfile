FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

# Add repository that contains the landscape server
RUN apt-get update && \
    apt-get -fy install software-properties-common && \
    add-apt-repository ppa:landscape/18.03
RUN apt-get update && \
    apt-get -fy dist-upgrade && \
    apt-get -fy install landscape-server

# Save default files to separate directory
RUN mkdir /data && \
    mv /var/lib/landscape /data && \
    mv /var/lib/landscape-server /data

COPY assets/landscape.conf /etc/landscape/service.conf

COPY assets/service-entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

CMD ["/sbin/entrypoint.sh"]
