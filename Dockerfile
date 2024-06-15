# Use an official Ruby runtime as a parent image
FROM ruby:3.1.6-slim-bookworm

# Install Node.js
RUN apt update && apt install -y curl
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -
RUN apt install -y nodejs

# Install Redis
RUN apt install -y redis-server

# Add the current directory contents into the container at /app
ADD . /app

# Install Node.js dependencies
WORKDIR /app/xmltool/web/frontend
RUN npm ci

# Install Ruby dependencies
WORKDIR /app
RUN apt install -y make gcc
RUN bundle install

EXPOSE 4567

# Start Redis and the Ruby application
CMD (redis-server &) && (ruby xmltool.rb)