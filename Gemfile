def next?
  File.basename(__FILE__) == "Gemfile.next"
end
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby '3.4.10'

gem 'rails', '~> 7.0.10'

# Ruby 3.4 moved these stdlib libraries out of the default gems; Rails 7.0 still
# requires them implicitly, so they have to be declared here.
gem 'base64'
gem 'benchmark'
gem 'bigdecimal'
gem 'drb'
gem 'logger'
gem 'mutex_m'
gem 'ostruct'

gem 'sass-rails', '~> 6.0'
gem 'puma', '~> 6.6'
gem 'pg'
gem 'terser'
gem 'jquery-rails'

# views
gem 'bootstrap-sass'
gem 'will_paginate'
gem 'will_paginate-bootstrap'

group :development, :test do
  gem 'better_errors'

  gem 'binding_of_caller'

  gem 'capybara'

  # Rails 7.0 is not compatible with minitest 6 (it drops minitest/mock and
  # other APIs rails/test_help relies on).
  gem 'minitest', '~> 5.25'
  gem 'minitest-reporters'
  gem 'factory_bot_rails'
end

group :development do
  gem 'listen', '~> 3.9'
  gem 'letter_opener'
end
