class User < ActiveRecord::Base
	validate :username, :uniqueness => true
	validate :oauth_token, :uniqueness => true
	validate :oauth_secret, :uniqueness => true

	has_many :tweets

	def twitter_client
		@twitter_client ||= Twitter::Client.new(:oauth_token => self.oauth_token,
																						:oauth_token_secret => self.oauth_secret)
	end

	def fetch_tweets!
    options = {}
    if last_tweet = self.tweets.order('created_at DESC').first
      options[:since_id] = last_tweet.twitter_id
    end

    timeline = twitter_client.user_timeline(self.username, options)
    timeline.each do |tweet|
      self.tweets.create(:text => tweet[:text], :twitter_id => tweet[:id])
    end
  end
end

# user = user.find(10)
# user.twitter_client.update('Weeeeeeeeee...')