# Open-RTC server in minimal Docker (for production)
#
# This Dockerfile creates a container which builds Open-RTC as found in the
# current folder.
#
# Create the image:
#
#   ```
#   docker build -t open-rtc -f Dockerfile .
#   ```
#
# Afterwards run the container like this:
#
#   ```
#   docker run --rm --name my-open-rtc -p 8080:8080 -p 8443:8443 \
#       -v `pwd`:/srv/extra -i -t open-rtc
#   ```
#
# Now you can either use a frontend proxy like Nginx to provide TLS to Spreed
# WebRTC and even run it in production like that from the Docker container, or
# for easy development testing, the container also provides a TLS listener with
# a self-signed certificate on port 8443.
#
# To use custom configuration, use the `server.conf.in` file as template and
# remove the listeners from [http] and [https] sections. Then provide that file
# when running the docker container as with `-c` parameter like this:
#
#   ```
#   docker run --rm --name my-open-rtc -p 8080:8080 -p 8443:8443 \
#       -v `pwd`:/srv/extra -i -t open-rtc \
#       -c /srv/extra/server.conf
#   ```
#
# And last, this container checks environment variables NEWCERT and NEWSECRETS,
# on startup. Set those to `1` to regenerate the corresponding values on start.
# The current certificate and secrets are printed before startup so you can use
# them easily for other services. Of course, if you want to have persistent cert
# and secrets, the container needs to be persistent in the first place, so no
# `--rm` parameter in the example from above in that case.
#

FROM ubuntu:xenial
LABEL maintainer="Simon Eisenmann <simon@struktur.de>"

# Set locale.
RUN apt-get clean && apt-get update
RUN apt-get install locales
RUN locale-gen --no-purge en_US.UTF-8
ENV LC_ALL en_US.UTF-8

ENV DEBIAN_FRONTEND noninteractive

# Base build dependencies.
RUN apt-get update && apt-get install -qy \
	golang \
	nodejs \
	build-essential \
	git \
	automake \
	autoconf

# Add and build Open-RTC server.
ADD . /srv/open-rtc
WORKDIR /srv/open-rtc
RUN mkdir -p /usr/share/gocode/src
RUN ./autogen.sh && \
	./configure && \
	make pristine && \
	make get && \
	make tarball
RUN rm /srv/open-rtc/dist_*/*.tar.gz
RUN mv /srv/open-rtc/dist_*/open-rtc-* /srv/open-rtc/dist



# Once application has been built, prepare production image
FROM frolvlad/alpine-glibc:alpine-3.3_glibc-2.23
LABEL maintainer="Simon Eisenmann <simon@struktur.de>"

# Add Open-RTC as provided by builder
COPY --from=0 /srv/open-rtc/dist /srv/open-rtc/dist

# Add entrypoint required by run.
COPY scripts/docker_entrypoint.sh /srv/entrypoint.sh

ENV LANG=C.UTF-8

# Add dependencies.
RUN apk add --no-cache \
	openssl

# Move around stuff from tarball to their expected locations.
RUN mv /srv/open-rtc/dist/loader/* /srv/open-rtc && \
	rm -rf /srv/open-rtc/dist/loader && \
	mv /srv/open-rtc/dist/www/html /srv/open-rtc && \
	mv /srv/open-rtc/dist/www/static /srv/open-rtc && \
	rm -rf /srv/open-rtc/dist/www

# Create default config.
RUN cp -v /srv/open-rtc/server.conf.in /srv/open-rtc/default.conf && \
	sed -i 's|listen = 127.0.0.1:8080|listen = 0.0.0.0:8080|' /srv/open-rtc/default.conf && \
	sed -i 's|;root = .*|root = /srv/open-rtc|' /srv/open-rtc/default.conf && \
	sed -i 's|;listen = 127.0.0.1:8443|listen = 0.0.0.0:8443|' /srv/open-rtc/default.conf && \
	sed -i 's|;certificate = .*|certificate = /srv/cert.pem|' /srv/open-rtc/default.conf && \
	sed -i 's|;key = .*|key = /srv/privkey.pem|' /srv/open-rtc/default.conf && \
	touch /etc/open-rtc-server.conf

# Cleanup.
RUN rm -rf /tmp/* /var/cache/apk/*

# Add mount point for extra things.
RUN mkdir /srv/extra
VOLUME /srv/extra

# Tell about our service.
EXPOSE 8080
EXPOSE 8443

# Define entry point with default command.
ENTRYPOINT ["/bin/sh", "/srv/entrypoint.sh", "-dc", "/srv/open-rtc/default.conf"]
CMD ["-c", "/etc/open-rtc-server.conf"]
