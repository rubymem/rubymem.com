# rubysec.com

Rails app that powers [rubysec.com](https://rubysec.com).

Pull requests welcome.

## Setup

Requires ruby-2.3.1

`bundle install`

`bundle exec rake db:create db:migrate`

### Load advisory database
```ruby
# inside a console
RubyImporter.new.import!
```

### Run the tests
`bundle exec rake test`
