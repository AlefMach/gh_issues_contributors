include .env

build:
	docker compose build

setup:
	make build && make mix_deps && make start

mix_deps:
	docker compose run --rm -v ~/.ssh:/root/.ssh gh_issues_contributors mix deps.get

format:
	docker compose run --rm gh_issues_contributors mix format mix.exs "lib/**/*.{ex,exs}" "test/**/*.{ex,exs}"

start:
	docker compose up

remove:
	docker compose stop && docker-compose rm -f

recreate:
	make build && docker compose up --force-recreate -d

exec:
	docker exec -it admin_gh_issues_contributors bash