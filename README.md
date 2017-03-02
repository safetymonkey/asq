![ASQ: Automated SQL Queries][asq-logo]
================================================================================

[![CircleCI][build-badge]][build]
[![Codecov][codecov-badge]][codecov]
<!-- [![License][license-badge]][license] -->

Asq is a tool for the automated retrieval and delivery of datasets obtained via SQL query. Administrators manage a central set of database connections and authorized users may then use those connections to create monitors and reports. Monitors return results and go into alert only if certain criteria are met on the result set, whereas reports return results consistently. The queries can be run on individually set schedules and once a result set is returned those results can be delivered via email, FTP, or SFTP.

[Demo](http://asq-monitoring.herokuapp.com)

Dependencies
---

Asq is a Ruby on Rails application with the following pre-requisites:

-   Ruby 2.3.3 + the 'bundler' gem
-   Rails 5.0.1
-   Postgres 9

Setup
---
Setup is straightforward. The following commands will help you download the application, set it up, verify that all tests are passing, and then start the application.

1. Clone the repository
```sh
$ git clone https://github.com/safetymonkey/asq.git
$ cd asq
```
2. __TODO:__ Add instructions for editing the plugins config file

3. Install the required gems and set up the cron job
The crontab is used to hit an endpoint every minute that scans for queries that are ready for a refresh.
```sh
$ bundle install --without production
$ cp templates/Asq.crontab /etc/cron.d/Asq
```
4. Setup the database
Ensurre that you have Postgres running and have created credentials that match your _config/database.yml_ file. By default, development environments have a user of _asq_ and a password of _password_. You can either give this user permissions to create databases or create the _asq_development_ and _asq_test_ databases manually and then give your service account permissions to those databases. Then execute the following rake task:
```sh
$ bundle exec rake db:setup
```
5. Verify that tests are passing
```sh
$ bundle exec rspec
```
6. Start the application
You'll need to start the primary front-end application as well as the back-end Delayed Job workers
```
$ bundle exec rails start
$ bin/delayed_job start -n <number of workers you want to start>
```
7. __TODO:__ Add some instruction regarding setting up the cron job


Contributing
--

If you make improvements to this application, please share with others.

-   Fork the project on GitHub.
-   Make your feature addition or bug fix.
-   Commit with Git.
-   Send the author a pull request.

If you add functionality to this application, create an alternative
implementation, or build an application that is similar, please contact
me and I’ll add a note to the README so that others can find your work.

## Creators

**Jon Grover**

- <https://twitter.com/safetymonkey>
- <https://github.com/safetymonkey>

**Greg HXC**

- <https://twitter.com/greghxc>
- <https://github.com/greghxc>



## Copyright and license

Code and documentation copyright 2011-2017 the [authors](https://github.com/twbs/bootstrap/graphs/contributors). Orginally developed for [Marchex, Inc.](https://marchex.com) ([Github](https://github.com/marchex)). Code released under the [MIT License](https://github.com/safetymonkey/asq/blob/master/LICENSE.txt).

[asq-logo]: images/asq-sml.png

[build-badge]: https://circleci.com/gh/safetymonkey/asq.svg?style=shield&circle-token=c31d4d2749473c316cd4fc5d6160be680a1dc9be
[build]: https://circleci.com/gh/safetymonkey/asq

[license-badge]: images/license-badge.svg
[license]: https://github.com/fastlane/fastlane/blob/master/LICENSE

[codecov-badge]:https://codecov.io/gh/safetymonkey/asq/branch/master/graph/badge.svg?token=gZGSAnU9hS
[codecov]: https://codecov.io/gh/safetymonkey/asq
