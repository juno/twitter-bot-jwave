require "oauth"
require "json"
require "typhoeus"
require "oauth/request_proxy/typhoeus_request"

module Twitter
  OAUTH_SITE = "https://api.twitter.com".freeze
  TWEETS_URL = "https://api.twitter.com/2/tweets".freeze
  USER_AGENT = "twitter-bot-jwave".freeze

  def self.tweet(text)
    consumer_key = ENV["TWITTER_CONSUMER_KEY"]
    consumer_secret = ENV["TWITTER_CONSUMER_SECRET"]
    access_token = ENV["TWITTER_TOKEN"]
    access_token_secret = ENV["TWITTER_SECRET"]

    # OAuth Consumerオブジェクトを作成
    consumer = OAuth::Consumer.new(
      consumer_key,
      consumer_secret,
      site: 'https://api.twitter.com',
      debug_output: false,
    )

    # OAuth Access Tokenオブジェクトを作成
    access_token = OAuth::AccessToken.new(consumer, access_token, access_token_secret)

    # OAuthパラメータをまとめたハッシュを作成
    oauth_params = {
      consumer: consumer,
      token: access_token,
    }

    options = {
      method: :post,
      headers: {
        "User-Agent": USER_AGENT,
        "content-type": "application/json"
      },
      body: JSON.dump({ "text" => text })
    }
    request = Typhoeus::Request.new(TWEETS_URL, options)
    oauth_helper = OAuth::Client::Helper.new(request, oauth_params.merge(:request_uri => TWEETS_URL))
    request.options[:headers].merge!({"Authorization" => oauth_helper.header}) # Signs the request
    response = request.run
    $stdout.puts response.code, JSON.pretty_generate(JSON.parse(response.body))
    response
  end
end
