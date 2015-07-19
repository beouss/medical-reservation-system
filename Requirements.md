# Introduction #

This project depends on set of plugins

  * http://github.com/technoweenie/restful-authentication/tree/master
> > `git clone git://github.com/technoweenie/restful-authentication.git restful_authentication`
  * http://elitists.textdriven.com/svn/plugins/acts_as_state_machine/trunk
  * http://code.google.com/p/rolerequirement/
  * http://github.com/mislav/will_paginate
  * http://github.com/pluginaweek/table_helper
  * Fork of matthuhiggins/foreigner: http://github.com/wkoziej/foreigner
  * sms\_fu???

It depends also on some database. E.g on debian you can use
`apt-get install libpgsql-ruby`

# Instalation #

`svn checkout http://medical-reservation-system.googlecode.com/svn/trunk/ medical-reservation-system-read-only`

`cd medical-reservation-system-read-only/mrs`

Read the proper manual of required plugins. Install them into ` vendor/plugins `

Create db user for test
`createuser test_db -P`

Configure application `rake db:create` and `rake db:migrate`

Run appliaction `./script/server`

Test it in browser `http://localhost:3000/`