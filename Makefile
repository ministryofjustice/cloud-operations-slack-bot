#!make
-include .env
export

UID=$(shell id -u)
DOCKER_COMPOSE = env UID=$(UID) docker-compose -f docker-compose.yml

build:
	$(DOCKER_COMPOSE) build

db-setup:
	$(DOCKER_COMPOSE) run --rm app bundle exec rails db:drop db:create db:migrate

run: build
	$(DOCKER_COMPOSE) up

test: build
	$(DOCKER_COMPOSE) run --rm app bundle exec rake

stop:
	$(DOCKER_COMPOSE) down

deploy:
	helm upgrade cloudopsbot-prod cloudopsbot \
		--set image.repository=$$ECR_URL \
		--set rails.secret_key_base=$$SECRET_KEY_BASE \
		--set slack.signing_secret=$$SLACK_SIGNING_SECRET \
		--set slack.oauth_token=$$SLACK_OAUTH_TOKEN