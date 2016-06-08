#!/usr/bin/env ruby

require 'em-twitter'
require 'httparty'
require 'json'
require 'uri'
require 'yaml'

@config = YAML.load_file(
  File.join(File.dirname(File.dirname(__FILE__)), 'config.yml')
)

def store(json_str)
  JSON.parse(json_str) # Checking format
  HTTParty.post(
    URI.join(@config['es_host'], "/twitter/userstream"),
    body: json_str,
  )
end

twitter_params = {
  :method => 'GET',
  :host   => 'userstream.twitter.com',
  :path   => '/1.1/user.json',
  :oauth  => {
    :consumer_key     => @config['consumer_key'],
    :consumer_secret  => @config['consumer_secret'],
    :token            => @config['oauth_token'],
    :token_secret     => @config['oauth_token_secret'],
  }
}

error_count = 0
EM.run do
  stream = EM::Twitter::Client.connect(twitter_params)
  stream.each do |result|
    begin
      store(result)
      error_count = 0
    rescue => e
      STDERR.puts [Time.now, *e.backtrace].join("\n")
      p result
      error_count += 1
      break if 5 <= error_count
      next
    end
  end
end
