# rubymem.com

Rails app that powers [rubymem.com](https://rubymem.com).

Pull requests welcome.

## Setup

Requires ruby-2.3.1

`bundle install`

`bundle exec rake db:create db:migrate`

### Load advisory database
```ruby
# inside a console
RubysecImporter.new.import!
```

### Run the tests
`bundle exec rake test`
