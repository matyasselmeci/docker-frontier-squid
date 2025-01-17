# Specify the opensciencegrid/software-base image tag
ARG YUM_BASE_REPO=testing

FROM opensciencegrid/software-base:3.5-el8-$YUM_BASE_REPO

LABEL maintainer OSG Software <help@opensciencegrid.org>

# Create the squid user with a fixed GID/UID; do this first, so that the Squid
# install does not do it.  Then do the installs.  All one instruction to reduce
# image size, etc.
RUN groupadd -o -g 10941 squid && \
    useradd -o -u 10941 -g 10941 -s /sbin/nologin -d /var/lib/squid squid && \
    yum update -y && \
    yum install -y frontier-squid && \
    rm -rf /var/cache/yum/* && \
    mkdir /etc/squid/customize.d

COPY 60-image-post-init.sh /etc/osg/image-config.d/60-image-post-init.sh
COPY start-frontier-squid.sh /usr/sbin/
COPY squid-customize.sh /etc/squid/customize.sh
COPY customize.d/* /etc/squid/customize.d/
COPY supervisor-frontier-squid.conf /etc/supervisord.d/40-frontier-squid.conf

EXPOSE 3128

# These env variables can be changed in the container instance
# Set default values which should reflect what is in the RPM
ENV SQUID_IPRANGE="10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 fc00::/7 fe80::/10"
ENV SQUID_CACHE_MEM="128 MB"
ENV SQUID_CACHE_DISK="10000"
ENV SQUID_CACHE_DISK_LOCATION="/var/cache/squid"
