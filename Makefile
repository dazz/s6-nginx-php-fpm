PHONY: *

install: up

up: down
	docker compose up --build -d app

down:
	docker compose down app --remove-orphans

stop:
	docker compose stop

logs:
	docker compose logs app -f

# build and play around with s6-overlay
build-s6:
	docker build -t dazz/s6-overlay:latest -f docker/s6-overlay/Dockerfile .

run-s6:
	docker run --rm -it --name try-s6 -d -p 8082:80 dazz/s6-overlay:latest

top-s6:
	docker top try-s6 acxf

# build and play around with alpine and php-fpm
alpine:
	docker run --rm -it --name alpine alpine:latest

php-fpm:
	docker run --rm -it -d --name php-fpm php:8.2-fpm-alpine

tree:
	tree --gitignore -C

# run it like this: make create-oneshot name=something
create-oneshot:
	mkdir -p docker/app/root/etc/s6-overlay/s6-rc.d/$(name)/dependencies.d
	touch docker/app/root/etc/s6-overlay/s6-rc.d/$(name)/dependencies.d/base
	echo "/etc/s6-overlay/scripts/$(name)" >| docker/app/root/etc/s6-overlay/s6-rc.d/$(name)/up
	echo "oneshot" >| docker/app/root/etc/s6-overlay/s6-rc.d/$(name)/type
	echo "#!/bin/sh" >| docker/app/root/etc/s6-overlay/scripts/$(name)
	chmod +x docker/app/root/etc/s6-overlay/scripts/$(name)

# run it like this: make create-longrun name=something
create-longrun:
	mkdir -p docker/app/root/etc/s6-overlay/s6-rc.d/$(name)/dependencies.d
	touch docker/app/root/etc/s6-overlay/s6-rc.d/$(name)/dependencies.d/base
	echo "#!/command/execlineb -P"  >| docker/app/root/etc/s6-overlay/s6-rc.d/$(name)/run
	echo "longrun" >| docker/app/root/etc/s6-overlay/s6-rc.d/$(name)/type