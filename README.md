# Jenkins Statistics

[![Build Status](https://travis-ci.org/reevoo/jenkins_statistics.svg?branch=master)](https://travis-ci.org/reevoo/jenkins_statistics)
[![Code Climate](https://codeclimate.com/github/reevoo/jenkins_statistics/badges/gpa.svg)](https://codeclimate.com/github/reevoo/jenkins_statistics)
[![Test Coverage](https://codeclimate.com/github/reevoo/jenkins_statistics/badges/coverage.svg)](https://codeclimate.com/github/reevoo/jenkins_statistics/coverage)
[![Issue Count](https://codeclimate.com/github/reevoo/jenkins_statistics/badges/issue_count.svg)](https://codeclimate.com/github/reevoo/jenkins_statistics)
[![Docker Repository on Quay](https://quay.io/repository/reevoo/jenkins_statistics/status "Docker Repository on Quay")](https://quay.io/repository/reevoo/jenkins_statistics)



Application for gathering and displaying statistical data about jenkins project builds.

# How does it work?
This application retrives data about builds from jenkins, analyses them and it creates some reports that are pushed to a dashboard for display.
It uses [Dashing](http://shopify.github.com/dashing) to display the reports.

## Installation

```ruby
$ bundle install
cp .env.example .env
```

## Dashboard setup
  - Follow the instructions from [here](http://shopify.github.io/dashing/) to install the dashboard
  - Fill in .env file with the names of the projects for each type of report
  - Create a template for your reports
    - you can copy the template examples from [/dashing_templates](dashing_templates)

## Usage

To update the reports execute:

```ruby
$ bundle exec dotenv rake update_dashboard
```

## Contributing

Bug reports and pull requests are welcome.

## License

This application is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

![alt tag](https://raw.githubusercontent.com/reevoo/jenkins_statistics/master/dashing_templates/project_1.png?raw=true)
