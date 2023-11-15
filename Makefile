PHONY: *

install: symfony-demo up

symfony-demo:
	git clone https://github.com/symfony/demo.git app

up: down
	docker compose up --build -d

down:
	docker compose down --remove-orphans

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