
FROM ubuntu:18.04

MAINTAINER Parchment Chef <chef@parchment.com>

# Install wget and other packages
RUN set -x \
    && sed -i 's/http:\/\/archive.ubuntu.com\/ubuntu/mirror:\/\/mirrors.ubuntu.com\/mirrors.txt/' /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y ruby-tzinfo wget ca-certificates apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# ARGs and ENVs for Chef Supermarket installation
ARG CHEF_SUPERMARKET_VERSION=3.2.0
ARG CHEF_SUPERMARKET_DOWNLOAD_SHA256=68ab0c2439bf0a7c4e245105c9c8c18c17e752dea069e4279c7057660c966dc2
ENV CHEF_SUPERMARKET_VERSION ${CHEF_SUPERMARKET_VERSION}
ENV CHEF_SUPERMARKET_DOWNLOAD_URL https://packages.chef.io/files/stable/supermarket/${CHEF_SUPERMARKET_VERSION}/ubuntu/18.04/supermarket_${CHEF_SUPERMARKET_VERSION}-1_amd64.deb
ENV CHEF_SUPERMARKET_DOWNLOAD_SHA256 ${CHEF_SUPERMARKET_DOWNLOAD_SHA256}

# Download and install the Chef-Supermarket package
RUN set -x \
    && wget --no-check-certificate -O supermarket_"$CHEF_SUPERMARKET_VERSION"-1_amd64.deb "$CHEF_SUPERMARKET_DOWNLOAD_URL" \
    && echo "$CHEF_SUPERMARKET_DOWNLOAD_SHA256 supermarket_$CHEF_SUPERMARKET_VERSION-1_amd64.deb" | sha256sum -c - \
    && dpkg -i supermarket_"$CHEF_SUPERMARKET_VERSION"-1_amd64.deb \
    && rm supermarket_"$CHEF_SUPERMARKET_VERSION"-1_amd64.deb \
    && mkdir /etc/cron.hourly /etc/cron.weekly /etc/init /var/log/supermarket

# Volumes
VOLUME ["/etc/supermarket", "/var/opt/supermarket"]

# Copy Entrypoint file
COPY scripts/* /

# Set Entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Expose ports
EXPOSE 80 443

# Set WORKDIR
WORKDIR /opt/supermarket/
