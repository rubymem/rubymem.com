<div style="text-align: center; width: 500px;">
  <img width="200" height="100" src="/logo/rubymem-logo.png">
</div>

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
