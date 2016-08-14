require 'dotenv'
require 'koala'

Dotenv.load

facebook_api = Koala::Facebook::API.new(ENV['ACCESS_TOKEN'], ENV['SECRET'])

file = "/tmp/#{Time.now.to_i}.jpg"
`raspistill -o #{file} #{ENV["RASPISTILL_OPTS"]}`
puts "#{file}: saved picture"

ret = facebook_api.put_picture(file, message: "captured at #{Time.now.strftime("%Y-%m-%d %H:%M")}")
puts "posted: #{ret}"

FileUtils.remove_file(file)
