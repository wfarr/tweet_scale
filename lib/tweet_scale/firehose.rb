require_relative '../tweet_scale'
Bundler.require(:firehose)

module TweetScale
  class Firehose
    def self.listen
      EventMachine::run do
        stream = Twitter::JSONStream.connect(
          :path           => '/1/statuses/filter.json',
          :auth           => 'testeroftests:sekret',
          :port           => 443,
          :ssl            => true,
          :method         => 'POST',
          :content        => 'track=tweetscale,atlrug,riak,ruby,rails'
        )

        stream.each_item do |item|
          json = JSON.parse(item)
          h = {
            :id                => json['id'],
            :text              => json['text'],
            :retweeted         => json['retweeted'],
            :created_at        => json['created_at'],
            :user              => {
              :id              => json['user']['id'],
              :screen_name     => json['user']['screen_name'],
              :followers_count => json['user']['followers_count']
            }
          }

          riak               = Riak::Client.new(:protocol => "pbc")
          tweets             = riak.bucket('tweets')
          tweet              = tweets.get_or_new "#{h[:user][:screen_name]}-#{h[:id]}"
          tweet.data         = h
          tweet.content_type = "application/json"
          tweet.store

          $stdout.print "indexed: #{h.to_json}\n"
          $stdout.flush
        end

        stream.on_error do |message|
          $stdout.print "error: #{message}\n"
          $stdout.flush
        end

        stream.on_reconnect do |timeout, retries|
          $stdout.print "reconnecting in: #{timeout} seconds\n"
          $stdout.flush
        end

        stream.on_max_reconnects do |timeout, retries|
          $stdout.print "Failed after #{retries} failed reconnects\n"
          $stdout.flush
        end

        trap('TERM') do
          stream.stop
          EventMachine.stop if EventMachine.reactor_running? 
        end
      end
    end
  end
end

