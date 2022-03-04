# syntax=docker/dockerfile:1
FROM ruby:3.0.3

ARG UID=1001
ARG GROUP=app
ARG USER=app
ARG HOME=/home/$USER
ARG APPDIR=$HOME/cloud-operation-slack-bot

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

RUN groupadd -g $UID -o $GROUP && \
  useradd -m -u $UID -g $UID -o -s /bin/false $USER && \
  mkdir -p $APPDIR && \
  chown -R $USER:$GROUP $HOME

USER $USER
WORKDIR $APPDIR

COPY --chown=$USER:$GROUP Gemfile $APPDIR/Gemfile
COPY --chown=$USER:$GROUP Gemfile.lock $APPDIR/Gemfile.lock

RUN bundle install

COPY --chown=$USER:$GROUP . $APPDIR

# Add a script to be executed every time the container starts.
COPY --chown=$USER:$GROUP entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]