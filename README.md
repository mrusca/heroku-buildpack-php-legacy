# Legacy Fork

## Goals

* more extensions
* more convenience when building and using your own support assets
* compatibility with non-Heroku platforms
* compatibility with private legacy apps

### Compatibility

Target platforms and builders:

* [Heroku](https://heroku.com) and [cedar-14](https://devcenter.heroku.com/articles/cedar)
* [dokku](https://github.com/progrium/dokku) and [progrium/buildstep](https://github.com/progrium/buildstep)
* [flynn](https://flynn.io/) and [flynn/slugrunner](https://github.com/flynn/flynn/tree/master/slugrunner)

HHVM compatibility is not explicitly supported.

#### Assets

Assets can be built for Ubuntu 14.04 LTS (Heroku's `cedar-14`) or older versions of Ubuntu. But this buildpack
will be tested against mostly 14.04.

*If you switch between Ubuntu versions, you may find that your compiled assets will no longer work.*

## Differences from the offical upstream buildpack

### Legacy

This is based off of an older fork of the official buildpack. The official buildpack utilises a different structure
and many other features that have been added since our parent fork was last updated. While it would be ideal to 
base our fork of off the official upstream, the author cannot currently get PHP to compile correctly with `pdo_dblib`.
However, in order to ease development, certain features have been ported from the official buildpack - notably
a Dockerfile for use in compilation of binaries etc.

### `compile`

Allow for 'in-place' compilation - useful for local development environment usage.

### Libraries

* [FreeTDS](http://www.freetds.org/)
* [libyaml](http://pyyaml.org/wiki/LibYAML)

### PHP

Compiled-in:

* [pdo_dblib](http://uk1.php.net/manual/en/ref.pdo-dblib.php)

Extensions:

* [igbinary](https://github.com/igbinary/igbinary)
* [libevent](http://php.net/libevent)
* [phalcon](phalconphp.com) (older v1.3.4 as default)
* [yaml](http://php.net/manual/en/book.yaml.php)

### nginx

* compiled with stub status module

----------------------------

# Heroku buildpack: PHP

This is a [Heroku buildpack](http://devcenter.heroku.com/articles/buildpacks) for PHP applications.

It uses Composer for dependency management, supports PHP or HHVM (experimental) as runtimes, and offers a choice of Apache2 or Nginx web servers.

## Usage

You'll need to use at least an empty `composer.json` in your application.

    heroku config:set BUILDPACK_URL=https://github.com/heroku/heroku-buildpack-php
    echo '{}' > composer.json
    git add .
    git commit -am "add composer.json for PHP app detection"


Please refer to [Dev Center](https://devcenter.heroku.com/categories/php) for further usage instructions.

## Development

### Compiling Binaries

The folder `support/build` contains [Bob](http://github.com/kennethreitz/bob-builder) build scripts for all binaries and dependencies.

#### Building the Docker Image

**After every change to your formulae, perform the following** from the root of the Git repository (not from `support/build/_docker/`):

    $ docker build --tag heroku-php-build-cedar-14 --file $(pwd)/support/build/_docker/cedar-14.Dockerfile .

#### Configuration

File `env.default` contains a list of required env vars, some with default values. You can modify it with the values you desire, or pass them to `docker run` using `--env`.

Out of the box, you'll likely want to change `S3_BUCKET` and `S3_PREFIX` to match your info. Instead of setting `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in that file, it is recommended to pass them to `docker run` through the environment, or explicitly using `--env`, in order to prevent accidental commits of credentials.

#### Using the Docker Image

From the root of the Git repository (not from `support/build/_docker/`):

    docker run --tty --interactive --env-file=support/build/_docker/env.default heroku-php-build-cedar-14 /bin/bash

That runs with values from `env.default`; if you need to pass e.g. `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` because they are not already in your environment, do either:

    AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=... docker run --tty --interactive --env-file=support/build/_docker/env.default heroku-php-build-cedar-14 /bin/bash

or

    docker run --tty --interactive --env-file=support/build/_docker/env.default -e AWS_ACCESS_KEY_ID=... -e AWS_SECRET_ACCESS_KEY=... heroku-php-build-cedar-14 /bin/bash

You then have a shell where you can run `bob build` and so forth.

```term
$ bob build php-5.6.24
```

If this works, run `bob deploy` instead of `bob build` to have the result uploaded to S3 for you.

If the dependencies are not yet deployed, you can do so by e.g. running `bob deploy libraries/zlib`.