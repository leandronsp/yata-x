bash:
	@docker-compose run app bash

install.gems:
	@docker-compose run app bash -c "gem install pg byebug"

server:
	@docker-compose run \
		--name yatax \
		--rm \
		--service-ports \
		app \
		bash -c "ruby lib/server.rb"

pg.server:
	@docker-compose run \
		--name yataxdb \
		--rm \
		postgres

psql:
	@docker exec -it yataxdb bash -c "psql -U yatax yatax"

db.seed:
	@docker exec \
		yataxdb \
		bash -c "psql -U yatax yatax < /app/db/seed.sql"
