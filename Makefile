include .env
export

export PROJECT_ROOT=$(shell pwd)

env-up:
	@docker compose up -d todoapp-postgres

env-down:
	@docker compose down todoapp-postgres

env-cleanup:
	docker compose down todoapp-postgres port-forwarder
	rm -rf out/pgdata

migrate-create:
	docker compose run --rm todoapp-postgres-migrate \
	create \
	-ext sql \
	-dir /migrations \
	-seq "$(seq)"

migrate-up: 
	make migrate-action action=up

migrate-down:
	make migrate-action action=down


migrate-action:
	docker compose run --rm todoapp-postgres-migrate \
		-path /migrations \
		-database postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@todoapp-postgres:5432/${POSTGRES_DB}?sslmode=disable \
		"$(action)"

env-port-forward:
	docker compose up -d port-forwarder

env-port-close:
	docker compose down port-forwarder


todoapp-run:
	export LOGGER_FOLDER=${PROJECT_ROOT}/out/logs && \
	export POSTGRES_HOST=localhost && \
	go run cmd/todoapp/main.go

	
