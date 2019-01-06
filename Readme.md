docker-snipe-it
====================

Dockerfile for [Snipe-IT](https://snipeitapp.com/) ([github](https://github.com/snipe/snipe-it))

License
------------
Except the codes from origin, anothers are WTFPL2.
NO WARRANTY.

Installation
------------

### Configure `docker-compose.yml`

1. Change passwords and IDs
2. Run `docker-compose build`
3. Run `docker-compose up snipe`. Then, this should be error. Note `APP_KEY` and edit `docker-compose.yml`.
4. Run `docker-compose up -d`
5. Access from browser

Current version
------------

|Package|Version|Note|
|-------|-------|-------|
|Snipe-IT|v4.6.7|from github|
|PHP|php:7.2-fpm-alpine|Minor version is not specified|
|MySQL|5|Minor version is not specified|
