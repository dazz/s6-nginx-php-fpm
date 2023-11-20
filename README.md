# S6 nginx/php-fpm container

This is a simple container with nginx and php-fpm based on alpine linux.
To install all the dependencies and build the container run:

```bash
make install
```

Todo:
* [ ] Add UID/GID support in dev stage

## Directory structure


```
.
├── app
│  └── public
│    └── index.php
├── docker
│  └── app
│    ├── Dockerfile
│    └── root
│      ├── etc
│      │  ├── nginx
│      │  │  ├── nginx.conf
│      │  │  └── sites-enabled
│      │  │    └── default
│      │  └── s6-overlay
│      │    ├── s6-rc.d
│      │    │  ├── app
│      │    │  │  ├── dependencies.d
│      │    │  │  │  ├── base
│      │    │  │  │  └── nginx
│      │    │  │  ├── type
│      │    │  │  └── up
│      │    │  ├── nginx
│      │    │  │  ├── dependencies.d
│      │    │  │  │  └── php-fpm
│      │    │  │  ├── run
│      │    │  │  └── type
│      │    │  ├── php-fpm
│      │    │  │  ├── dependencies.d
│      │    │  │  │  └── base
│      │    │  │  ├── run
│      │    │  │  └── type
│      │    │  └── user
│      │    │    └── contents.d
│      │    │      └── app
│      │    └── scripts
│      │      └── app
│      └── usr
│        └── local
│          └── etc
│            ├── php
│            │  └── php.ini
│            └── php-fpm.conf
├── docker-compose.yml
├── Makefile
└── README.md
```
