# Dockerfile
FROM ruby:2.3

RUN apt-get update && apt-get install -y sqlite3 --no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y git \
                       curl \
                       build-essential \
                       libssl-dev

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/

RUN bundle install --without development test

COPY . /usr/src/app

EXPOSE 3000
EXPOSE 80
CMD ["ruby", "mailer.rb"]
