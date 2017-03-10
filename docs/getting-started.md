# Getting Started

Setup is straightforward. The following commands will help you download the application, set it up, verify that all tests are passing, and then start the application.

### Clone the repository
```sh
$ git clone https://github.com/safetymonkey/asq.git
$ cd asq
```
### Edit the features file
Open and edit _config/features.yml_. This contains on/off settings for the following features:
1. **LDAP Integration.** Defaults to false. If enabled, uses LDAP (as configured in _config/ldap.yml_ for authentication instead of an independent user database.
2. **PostgreSQL connection support.** Defaults to true. Enables Asqs to connect to Postgres database servers. Has underpinning library dependencies if enabled, per the [pg gem](https://bitbucket.org/ged/ruby-pg/wiki/Home).
3. **MySQL connection support.** Defaults to true. Enables Asqs to connect to MySQL database servers. Has underpinning library dependencies if enabled, per the [Mysql2 gem](https://github.com/brianmario/mysql2).
4. **Oracle connection support.** Defaults to true. Enables Asqs to connect to Oracle database servers. Has underpinning library dependencies if enabled, per the [ruby-oci8 gem](https://github.com/kubo/ruby-oci8).

### Install the required gems and set up the cron job
The crontab is used to hit an endpoint every minute that scans for queries that are ready for a refresh.
```sh
$ bundle install --without production
$ cp templates/Asq.crontab /etc/cron.d/Asq
```

### Setup the database
Ensure that you have Postgres running and have created credentials that match your _config/database.yml_ file. By default, development environments have a user of _asq_ and a password of _password_. You can either give this user permissions to create databases or create the _asq_development_ and _asq_test_ databases manually and then give your service account permissions to those databases. Then execute the following rake task:
```sh
$ bundle exec rake db:setup
```

### Verify that tests are passing
```sh
$ bundle exec rspec
```

### Start the application
You'll need to start the primary front-end application as well as the back-end Delayed Job workers
```
$ bundle exec rails start
$ bin/delayed_job start -n <number of workers you want to start>