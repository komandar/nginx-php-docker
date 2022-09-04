<div align="center">

# Nginx/PHP-FPM Docker Image

A lightweight combined Nginx/PHP-FPM Docker image.

[![Build Status](https://github.com/komandar/nginx-php-docker/workflows/build/badge.svg)](https://github.com/komandar/nginx-php-docker/actions)
[![Image Size](https://img.shields.io/docker/image-size/komandar/nginx-php)](https://hub.docker.com/repository/docker/komandar/nginx-php)
[![Docker Pulls](https://img.shields.io/docker/pulls/komandar/nginx-php)](https://hub.docker.com/repository/docker/komandar/nginx-php)
[![Licence](https://img.shields.io/github/license/komandar/nginx-php-docker)](LICENSE)

</div>

## Features

The following features work out of the box without any configuration:

- `Nginx` serves as the web host and reverse proxy
- `PHP-FPM/OPcache` for fast performance in the browser and on the CLI
- `msmtp` is installed and configured (see `config/msmtprc`) to send mail locally for testing via apps like `Mailcatcher` which will work out of the box (if Mailcatcher container is titled `mailcatcher`)
- `composer` is installed and ready to use to setup all your dependencies
- `mysql_pdo` is installed as the driver for MariaDB/Mysql connections
- `pgsql_pdo` is installed as the driver for Postgresql connections
- `gd` is installed for image processing
- `zip` is installed for items that may need that

## Platforms

This image offers platform support for the following architectures:

- linux/amd64
- linux/arm/v7
- linux/arm64

## Install

```bash
# Dockerfile
FROM: komandar/nginx-php:latest

# docker-compose
image: komandar/nginx-php:latest
```

## Usage

**Vanilla PHP and HTML**

Place your `PHP` or `HTML` site files into `/var/www/app/public` inside the container to get started with this image. This can be achieved by using a volume in a `docker-compose` file or by copying them over in a `Dockerfile`. If you are using HTML instead of PHP, ensure you remove the `index.php` file so that your `index.html` file can take priority.

**Laravel**

Place the root of your laravel project in `/var/www/app` so that the `public` folder of laravel lines up with the directory served by this nginx image (see `examples/laravel` for more details).

Want to give this image a spin? Simply run the following:

```bash
docker compose up -d
```

Once the container spins up, navigate to `http://localhost:8888` in a browser.

## Docker Tags

Tags for this image follow the syntax of `PHP_VERSION-IMAGE_VERSION`; for instance, a valid tag would be `8.1-v1` signifying to use PHP v8.1 and the first version of this image (nginx config, Dockerfile, etc).

**PHP Versions**

- `8.1` - uses the latest release on the PHP 8.1 Alpine track.

**Image Type**

- `dev` - uses extra configuration for development environments
- `prod` - strict prod settings enabled (includes opcache and jit)

**Standalone Tags**

- `latest` - uses the latest release of this image with all defaults.

## Development

**Note:** Alpine Linux does not keep old versions of packages. This image pins to the relative major version to try staying flexibile. Future builds may need to be altered if packages are no longer offered.

```bash
# Test nginx configuration
nginx -T
```

**Releasing**

When releasing this project, cut a new GitHub tag/release that includes the php version and iterates the release number (eg: 8.1-v4, 8.1-v5, 8.1-v6...). We won't use semver here for simplicity when tagging images.

### Building New Versions

This image supports swapping in the version number of PHP with a value from the official `PHP-FPM Alpine` [tag list](https://hub.docker.com/_/php).

**Automated Builds**

GitHub Actions will automatically build and push supported tags to Docker Hub on each new release. Additionally GitHub Actions will automatically build the `latest` tag on any push to the main branch. It is highly recommended that you use a versioned release of this image to avoid any transient changes introduced in any given `latest` build.

**Manual Builds**

```bash
docker build -t komandar/nginx-php:8.1-v1 --build-arg PHP_VERSION=8.1 .

sudo docker push komandar/nginx-php:8.1-v1
```
