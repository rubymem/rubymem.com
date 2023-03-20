def next?
  File.basename(__FILE__) == "Gemfile.next"
end
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby '3.1.3'

if next?
  gem 'rails', '~> 7.0.0'
else
  gem 'rails', '~> 6.1.0'
end

gem 'sass-rails', '~> 6.0'
gem 'puma', '~> 4.3'
gem 'pg'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'

# views
gem 'bootstrap-sass'
gem "font-awesome-rails"
gem 'will_paginate'
gem 'will_paginate-bootstrap'

# deployment
gem 'capistrano', '~> 3.4.0'
gem 'capistrano-rails', '~> 1.1'
gem 'capistrano-bundler', '~> 1.1.2'
gem 'capistrano-rails-console'
gem 'capistrano-deploytags', '~> 1.0.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'rb-readline'
  gem 'pry-byebug'
  gem 'better_errors'

  gem 'pry-rails'
  gem 'binding_of_caller'

  gem 'minitest-spec-rails'
  gem 'minitest-reporters'
  gem 'faker'
  gem 'factory_bot_rails'
  gem 'bundler-leak'
end

group :development do
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.1.0'
  gem 'letter_opener'
  gem 'annotate'
end
