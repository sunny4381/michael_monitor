require 'dotenv'
require 'koala'
require 'rmagick'

def to_gray(pixel)
  (pixel.red * 0.30 + pixel.green * 0.59 + pixel.blue * 0.11).to_i
end

Dotenv.load

facebook_api = Koala::Facebook::API.new(ENV['ACCESS_TOKEN'], ENV['SECRET'])

file = "/tmp/#{Time.now.to_i}.jpg"
`raspistill -o #{file} #{ENV["RASPISTILL_OPTS"]}`
puts "#{file}: saved picture"

img_list = Magick::ImageList.new(file)
img = img_list.first

sum_under = 0
img.each_pixel do |pixel, x, y|
  sum_under += 1 if to_gray(pixel) < 10_000
end

ratio_under = sum_under / (img.columns * img.rows).to_f
if ratio_under >= 0.8
  puts "too under"
  FileUtils.remove_file(file)
  exit 0
end

caption = "captured at #{Time.now.strftime("%Y-%m-%d %H:%M")}"
ret = facebook_api.put_picture(file, caption: caption)
puts "posted: #{ret}"

FileUtils.remove_file(file)
