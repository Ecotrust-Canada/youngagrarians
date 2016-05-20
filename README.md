Install
=======

1. Install docker & docker_machine
2. bin/start_dev_server (note that a docker-machine with a name starting with dev is expected)
3. Want to start with data?  Put a file with data in tmp/db_dump.sql

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

Heroku Repo
===========
- https://git.heroku.com/youngagrarians.git

youngagrarians
==============

Growing the next generation of farmers
