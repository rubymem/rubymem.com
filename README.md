<p align="center">
  <img width="250" height="250" src="/logo/rubymem-logo.png">
</p>

[![Build Status](https://travis-ci.org/ombulabs/rubymem.com.svg?branch=master)](https://travis-ci.org/ombulabs/rubymem.com)

Rails app that powers [rubymem.com](https://rubymem.com).

Pull requests welcome.

## Setup

Requires ruby-2.3.1

`bundle install`

`bundle exec rake db:create db:migrate`

### Load advisory database
```ruby
# inside a console
RubymemImporter.new.import!
```

### Run the tests
`bundle exec rake test`
