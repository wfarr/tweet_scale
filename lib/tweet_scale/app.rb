require_relative '../tweet_scale'
Bundler.require(:app)

module TweetScale
  class App < Sinatra::Base
    get '/' do
      erb :home
    end

    get '/tweets/:user' do |user|
      mr = ::Riak::MapReduce.new(riak)
      mr.filter('tweets') do
        matches "^#{user}-"
      end
      mr.map("function (v) { return [ JSON.parse(v.values[0].data) ]; }", keep: true)
      @tweets = mr.run

      erb :tweets
    end

    get '/search' do
      user = params[:user]
      redirect "/tweets/#{user}"
    end

    private
    def riak
      @riak ||= ::Riak::Client.new(:protocol => 'pbc')
    end

    def tweets
      riak.bucket('tweets')
    end
  end
end
