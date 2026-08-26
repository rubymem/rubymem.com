<p align="center">
  <img width="250" height="250" src="/logo/rubymem-logo.png">
</p>

[![CI](https://github.com/rubymem/rubymem.com/actions/workflows/tests.yml/badge.svg)](https://github.com/rubymem/rubymem.com/actions/workflows/tests.yml)

This is the Rails app that powers [RubyMem.com](https://www.RubyMem.com): A website
to submit new reports about gems which have memory leaks. Also, a nice way to
browse existing memory leak advisories.

## Setup

Requires the Ruby version in [.ruby-version.sample](.ruby-version.sample), and
Postgres.

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
bin/rails test
bin/rails test:system
```

The system tests drive the app through Capybara's `rack_test` driver, so they
need no browser or driver binaries.

[CI](.github/workflows/tests.yml) runs both commands against Postgres, once per
boot: `Gemfile` and `Gemfile.next`. To run the suite against the next boot
locally:

```
BUNDLE_GEMFILE=Gemfile.next bin/rails test
```

## Collaboration

New issues and pull requests are welcome. Read our [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before
submitting an issue or pull request. Thank you! ❤️

## FastRuby.io
![fastruby](https://github.com/rubymem/rubymem.com/raw/master/fastruby-logo.png)
`rubymem.com` is maintained and funded by FastRuby.io, inc. The names and logos for FastRuby.io are trademarks of FastRuby.io, inc.
