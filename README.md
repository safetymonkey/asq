![ASQ: Automated SQL Queries][asq-logo]
================================================================================

[![CircleCI][build-badge]][build]
[![Codecov][codecov-badge]][codecov]
<!-- [![License][license-badge]][license] -->

Asq is a tool for the automated retrieval and delivery of datasets obtained via SQL query. Administrators manage a central set of database connections and authorized users may then use those connections to create monitors and reports. Monitors return results and go into alert only if certain criteria are met on the result set, whereas reports return results consistently. The queries can be run on individually set schedules and once a result set is returned those results can be delivered via email, FTP, or SFTP.

[Demo](http://asq-monitoring.herokuapp.com)

Dependencies
---

Asq is a Ruby on Rails gem:

-   Ruby
-   Rails

Learn more about [Installing Rails](http://railsapps.github.io/installing-rails.html).

Database
---

This application uses PostgreSQL with ActiveRecord.

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
