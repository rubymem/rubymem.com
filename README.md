<p align="center">
  <img width="250" height="250" src="/logo/rubymem-logo.png">
</p>

[![Build Status](https://travis-ci.org/rubymem/rubymem.com.svg?branch=master)](https://travis-ci.org/rubymem/rubymem.com)

This is the Rails app that powers [RubyMem.com](https://www.RubyMem.com): A website
to submit new reports about gems which have memory leaks. Also, a nice way to
browse existing memory leak advisories.

## Setup

Requires ruby-2.5 or higher, and Postgres.

    ./bin/setup

### Seed

Setup steps will take care of this. If you want to reset your database, you
can remove all records from the database and then call:

```ruby
# ./bin/rails console
RubymemImporter.new.import!
```

## Testing

After making changes, make sure you run the test suite:

```
bundle exec rake test
```

## Collaboration

New issues and pull requests are welcome. Read our [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before
submitting an issue or pull request. Thank you! ❤️
