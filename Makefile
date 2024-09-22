PHONY: *

UID = $(shell id -u)
GID = $(shell id -g)

install: up

setup-db:
	docker compose exec app php bin/console doctrine:database:create --if-not-exists
	docker compose exec app php bin/console doctrine:schema:create --if-not-exists
	docker compose exec app php bin/console doctrine:fixtures:load

up: down
	docker compose build --build-arg UID=$(UID) --build-arg GID=$(GID)
	docker compose up -d

down:
	docker compose down app

cli:
	docker compose exec app /bin/sh

stop:
	docker compose stop

logs:
	docker compose logs app -f

tree:
	tree --gitignore -C --dirsfirst --noreport

s6-lint:
	docker run -it --rm -v ./docker/app/root/etc/s6-overlay:/etc/s6-overlay hakindazz/s6-cli:latest lint

s6-mermaid:
	docker run -it --rm -v ./docker/app/root/etc/s6-overlay:/etc/s6-overlay hakindazz/s6-cli:latest mermaid
