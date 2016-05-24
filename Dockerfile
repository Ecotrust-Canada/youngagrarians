FROM ruby:2.2.4-slim
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev libmysqlclient-dev nodejs git libxml2-dev libxslt1-dev mysql-client qt5-qmake qt5-default
RUN mkdir /ya
RUN gem cleanup
WORKDIR /ya
ENV BUNDLE_GEMFILE=/ya/Gemfile
ENV BUNDLE_JOBS=5
ENV BUNDLE_PATH=/bundle
ADD Gemfile* /ya/
RUN bundle install
# bundling happens first to get better docker cache behaviour
ADD . /ya
# TODO: package assets in a way friendly for docker cache
