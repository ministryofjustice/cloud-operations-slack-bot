#!make
-include .env
export

build:
	docker-compose build

start-db:
	docker-compose up -d db

db-setup: start-db
	docker-compose run --rm app ./bin/rails db:drop db:create

migrate: db-setup
	docker-compose run --rm app ./bin/rails db:migrate

serve: stop start-db
	docker-compose up app

run: serve

test: stop build start-db
	docker-compose run --rm app bundle exec rake

stop:
	docker-compose down

deploy:
	helm upgrade cloudopsbot-prod cloudopsbot \
		--set image.repository=$$ECR_URL \
		--set rails.secret_key_base=$$SECRET_KEY_BASE \
		--set slack.signing_secret=$$SLACK_SIGNING_SECRET \
		--set slack.oauth_token=$$SLACK_OAUTH_TOKEN \
		--set snow.basic_auth_username=$$SNOW_BASIC_AUTH_USERNAME \
		--set snow.basic_auth_password=$$SNOW_BASIC_AUTH_PASSWORD
