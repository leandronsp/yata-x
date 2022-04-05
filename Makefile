bash:
	@docker-compose run app bash

server:
	@docker-compose run \
		--name yatax \
		--rm \
		--service-ports \
		app \
		bash -c "ruby lib/server.rb"
