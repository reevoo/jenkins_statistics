# Jenkins Statistics

[![Build Status](https://travis-ci.org/ionut998/jenkins_statistics.svg?branch=master)](https://travis-ci.org/ionut998/jenkins_statistics)
[![Code Climate](https://codeclimate.com/github/ionut998/jenkins_statistics/badges/gpa.svg)](https://codeclimate.com/github/ionut998/jenkins_statistics)
[![Test Coverage](https://codeclimate.com/github/ionut998/jenkins_statistics/badges/coverage.svg)](https://codeclimate.com/github/ionut998/jenkins_statistics/coverage)
[![Issue Count](https://codeclimate.com/github/ionut998/jenkins_statistics/badges/issue_count.svg)](https://codeclimate.com/github/ionut998/jenkins_statistics)



Application for gathering and displaying statistical data about jenkins project builds.

# How it works
This application retrives data about builds from jenkins, analizes them and it creates some reports that are pushed to a dashboard for display.

## Installation

```ruby
bundle install
```

## Usage

To generate the reports execute:

```ruby
$ bundle exec update_dashboard
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ionut998/jenkins_statistics. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

This application is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
