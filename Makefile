#!make
-include .env
export

build:
	docker-compose build

run: build
	docker-compose up

test: build
	docker-compose run --rm app bundle exec rake

stop:
	docker-compose down

deploy:
	helm upgrade cloudopsbot-prod cloudopsbot \
		--set image.repository=$$ECR_URL \
		--set rails.secret_key_base=$$SECRET_KEY_BASE \
		--set slack.signing_secret=$$SLACK_SIGNING_SECRET \
		--set slack.oauth_token=$$SLACK_OAUTH_TOKEN