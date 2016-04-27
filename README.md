Install
=======

1. Install docker
2. bin/start_dev_server (note that a docker-machine starting with dev is expected)
2. Make sure database.yml is configured properly for you
3. `rake db:create`
4. `rake db:reset`
5. `RAILS_ENV=test rake db:schema:load` - setups up the test database

Production
=========

- Mount a volumen at config/secrets with devise_token & secure_token files ( generate with your preferred random token generator or rake secret > file_name)

Run
====

    rails s

Admin Panel
===========

To access the admin panel go to `/login` and login as the following user:

email: dentsara@gmail.com
password: test42


youngagrarians
==============

Growing the next generation of farmers
