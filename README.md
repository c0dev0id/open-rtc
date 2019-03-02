Open-RTC
===================

Open-RTC implements a WebRTC audio/video call and conferencing server
and web client.

The latest source of Open-RTC can be found on [GitHub](https://github.com/wargio/open-rtc). If you are a user, just wanting a secure and private alternative for online communication make sure to check out the [Spreedbox](http://spreedbox.com), providing a ready to use hardware with Open-RTC included.

(original project was https://github.com/strukturag/spreed-webrtc)

## Build prerequisites

  - [Go](http://golang.org) >= 1.4.0
  - [NodeJS](http://nodejs.org/) >= 0.6.0
  - [autoconf](http://www.gnu.org/software/autoconf/)
  - [automake](http://www.gnu.org/software/automake/)
  - [git](https://git-scm.com/)


## Runtime dependencies

Open-RTC compiles directly to native code and has no
external runtime dependencies. See [here](http://golang.org/doc/faq#How_is_the_run_time_support_implemented)
for details.


## Building

[![Build Status](https://travis-ci.org/wargio/open-rtc.png?branch=master)](https://travis-ci.org/wargio/open-rtc)

If you got open-rtc from the git repository, you will first need
to run the included `autogen.sh` script to generate the `configure`
script.

Configure does try to find all the tools on your system at the standard
locations. If the dependencies are somewhere else, add the corresponding
parameters to the ./configure call.

```bash
$ ./configure
$ make
  ```

On FreeBSD, the default `make` has a different syntax, so `gmake` must be used
there.


## Build separately

There are several make targets available. Get Go external dependencies at
least once with ``make get``, all the other targets depend on this.

```bash
$ make get
$ make assets
$ make binary
```


## Server startup

```bash
open-rtc-server [OPTIONS]
```

### Options

```
-c="./server.conf": Configuration file.
-cpuprofile="": Write cpu profile to file.
-h=false: Show this usage information and exit.
-l="": Log file, defaults to stderr.
-memprofile="": Write memory profile to this file.
-v=false: Display version number and exit.
```

An example configuration file can be found in server.conf.in.


## Usage

Connect to the server URL and port with a web browser and the
web client will launch.


## Development

To build styles and translations, further dependencies are required.
The source tree contains already built styles and translations, so
these are only required if you want to make changes.

  - [NodeJS](http://nodejs.org/) >= 0.10.0
  - [Compass](http://compass-style.org/) >= 1.0.0
  - [Sass](http://sass-lang.com/) >= 3.3.0
  - [Babel](http://babel.pocoo.org/)

The following Node.js modules are required, these may be installed
locally by running `npm install` from the project root. Consult the
`package.json` file for more details.

  - [autoprefixer](https://www.npmjs.org/package/autoprefixer) >= 1.1
  - [po2json](https://github.com/mikeedwards/po2json) >= 0.4.1
  - [JSHint](http://www.jshint.com/) >= 2.0.0
  - [scss-lint](https://github.com/causes/scss-lint) >= 0.33.0

Styles can be found in src/styles. Translations are found in src/i18n.
Each folder has its own Makefile to build the corresponding files. Check the
Makefile.am templates for available make targets.

Javascript console logging is automatically _disabled_ and can be enabled by
adding the query parameter `debug` to your url `https://my_url?debug`.


## Running server for development

Copy the server.conf.in to server.conf.

Build styles, javascript and binary using make. Then run
``./open-rtc-server``

The server runs on http://localhost:8080/ per default.

HTML changes and Go rebuilds need a server restart. Javascript
and CSS reload directly.


## Running for production

Open-RTC should be run through a SSL frontend proxy with
support for Websockets. Example configuration for Nginx can be
found in `doc/NGINX.txt`.

In addition, for real world use, one also needs a STUN/TURN server
configured (with shared secret support).

See https://github.com/coturn/coturn for a free
open source TURN server implementation. Make sure to use a recent
version (we recommend 3.2). Versions below 2.5 are not supported.

For WebRTC usage, be sure to enable long-term credentials,
fingerprinting, and set the realm. See
https://github.com/coturn/coturn/wiki/turnserver#webrtc-usage
for more information.


## Running with Docker

We provide official Docker images at https://hub.docker.com/r/spreed/webrtc/. Of
course you can build the Docker image yourself as well. Check the Dockerfiles in
this repository for details and instructions.

Use the following command to run a Open-RTC Docker container with the
default settings from our official Open-RTC Docker image.

```
docker run --rm --name my-open-rtc -p 8080:8080 -p 8443:8443 -v `pwd`:/srv/extra -i -t spreed/webrtc
```

## Contributing

1. "Fork" develop branch.
2. Create a feature branch.
3. Make changes.
4. Do your commits (run ``make fmt`` and ``make jshint`` before commit).
5. Send "pull request" for develop branch.


## License

`Open-RTC` uses the AGPL license, see our `LICENSE` file.
