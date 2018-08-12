FROM ruby:2.2.5-slim
RUN echo "bust cache 2"
RUN apt-get update -qq && apt-get install -y build-essential nodejs git  ruby-dev libffi-dev openssl \
  postgresql-common libpq-dev libmysqlclient-dev sqlite3 \
  libxml2 libxml2-dev libxslt1-dev \
  libgmp3-dev # required for json gem

RUN mkdir /ya

RUN gem cleanup
WORKDIR /ya
ENV BUNDLE_GEMFILE=/ya/Gemfile
ENV BUNDLE_JOBS=5
ENV BUNDLE_PATH=/bundle
ADD Gemfile* /ya/
RUN gem install ffi -v '1.9.10' # Fix sisue where this crashes  if not done beforehand; keep tagged to Gemfile.lock version (or remove )
RUN bundle install --retry 5 --jobs 2 --without=test
# bundling happens first to get better docker cache behaviour
ADD . /ya
RUN rake assets:precompile
RUN rm -f /ya/tmp/pids/server.pid
