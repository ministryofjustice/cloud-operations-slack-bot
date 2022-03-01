# syntax=docker/dockerfile:1
FROM ruby:3.0.3

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

WORKDIR /cloud-operation-slack-bot

COPY Gemfile /cloud-operation-slack-bot/Gemfile
COPY Gemfile.lock /cloud-operation-slack-bot/Gemfile.lock

RUN bundle install

COPY . /cloud-operation-slack-bot

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]