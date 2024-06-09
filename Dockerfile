# Use an official Ruby runtime as a parent image
FROM ruby:3.1.6-slim-bookworm

# Set the working directory in the container to /app
WORKDIR /app

# Add the current directory contents into the container at /app
ADD . /app

# Install dependencies
RUN apt update && apt install -y make gcc

# Install any needed packages specified in Gemfile
RUN bundle install

# Set the default command
ENTRYPOINT ["ruby", "xmltool.rb"]