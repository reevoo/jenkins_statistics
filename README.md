# Jenkins Statistics

[![Build Status](https://travis-ci.org/ionut998/jenkins_statistics.svg?branch=master)](https://travis-ci.org/ionut998/jenkins_statistics)
[![Code Climate](https://codeclimate.com/github/ionut998/jenkins_statistics/badges/gpa.svg)](https://codeclimate.com/github/ionut998/jenkins_statistics)
[![Test Coverage](https://codeclimate.com/github/ionut998/jenkins_statistics/badges/coverage.svg)](https://codeclimate.com/github/ionut998/jenkins_statistics/coverage)
[![Issue Count](https://codeclimate.com/github/ionut998/jenkins_statistics/badges/issue_count.svg)](https://codeclimate.com/github/ionut998/jenkins_statistics)



Application for gathering and displaying statistical data about jenkins project builds.

# How does it work?
This application retrives data about builds from jenkins, analizes them and it creates some reports that are pushed to a dashboard for display.
It uses [Dashing](http://shopify.github.com/dashing) to display the reports.

## Installation

```ruby
$ bundle install
cp .env.example .env
```

## Dashboard setup
  - Follow the instructions from [here](http://shopify.github.io/dashing/) to install the dashboard
  - Create a template for each of the projects that you added in BRIEF_REPORT_FOR and DETAILED_REPORT_FOR from [.env](.env.example)
    - you can copy the template examples from [/dashing_templates](dashing_templates)

## Usage

To update the reports execute:

```ruby
$ bundle exec rake update_dashboard
```

## Contributing

Bug reports and pull requests are welcome.

## License

This application is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
