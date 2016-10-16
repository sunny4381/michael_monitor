require 'dotenv'
require 'oauth2'

Dotenv.load

site = "https://graph.facebook.com"
token_url = "/oauth/access_token"
callback_url = "http://localhost/"

OAuth2::Response.register_parser(:text, 'text/plain') do |body|
  key, value = body.split('=')
  {key => value}
end

# code url
client = OAuth2::Client.new(ENV['APP_ID'], ENV['SECRET'], site: site, token_url: token_url)
puts "次のURLにアクセスし code を取得してください\n#{client.auth_code.authorize_url(redirect_uri: callback_url)}"

# get access token
puts "コードを入力してください:"
code = STDIN.gets
access_token = client.auth_code.get_token(code.strip, redirect_uri: callback_url)

# puts access token token
puts "access_token: #{access_token.token}"
