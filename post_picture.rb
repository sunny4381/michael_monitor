require 'dotenv'
require 'koala'
require 'rmagick'

Dotenv.load

facebook_api = Koala::Facebook::API.new(ENV['ACCESS_TOKEN'], ENV['SECRET'])

file = "/tmp/#{Time.now.to_i}.jpg"
`raspistill -o #{file} #{ENV["RASPISTILL_OPTS"]}`
puts "#{file}: saved picture"

img_list = Magick::ImageList.new(file)
img = img_list.first

sum_red = 0
sum_green = 0
sum_blue = 0
img.each_pixel do |pixel, x, y|
  sum_red += pixel.red
  sum_green += pixel.green
  sum_blue += pixel.blue
end

avg_red = sum_red / (img.columns * img.rows)
avg_green = sum_green / (img.columns * img.rows)
avg_blue = sum_blue / (img.columns * img.rows)

intensity = avg_red*0.30 + avg_green*0.59 + avg_blue*0.11

if intensity < 10_000
  puts "too under"
  FileUtils.remove_file(file)
  exit 0
end

caption = "captured at #{Time.now.strftime("%Y-%m-%d %H:%M")}"
ret = facebook_api.put_picture(file, caption: caption)
puts "posted: #{ret}"

FileUtils.remove_file(file)
