#!/bin/sh

main() {
    echo "Start webserver..."
    nginx
    php-fpm
}

main
