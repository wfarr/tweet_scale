source :rubygems
gem 'json_pure', :require => [ 'json' ]
gem 'riak-client', :require => [ 'riak' ]
gem 'pry'

group :firehose do
  gem 'excon'
  gem 'twitter-stream', :require => [ 'twitter/json_stream' ]
end

group :app do
  gem 'sinatra'
  gem 'unicorn'
end

group :development do
  gem 'foreman', :require => false
end

group :test do
  gem 'rack-test', :require => [ 'rack/test' ]
end
