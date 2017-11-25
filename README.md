imjac.in/ta Webcore
===

This is the framework that my website (http://imjac.in/ta) is based upon.
It is written in Ruby, utlizing Sinatra, Rack and Thin for the webservice.
Postgres is run for the database with the appropriate Sequel adapter.

Run with `./local_bootstrap` on a development system.

Install packages with `bundle install`.

Install the systemd service (in prod) with `./install_systemd.sh`.