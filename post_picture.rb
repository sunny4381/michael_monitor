require 'dotenv'
require 'koala'
require 'rmagick'

class Shot
  def initialize(opts = ENV["RASPISTILL_OPTS"])
    @opts = opts
  end

  def to_gray(pixel)
    (pixel.red * 0.30 + pixel.green * 0.59 + pixel.blue * 0.11).to_i
  end

  def sample_pixels(img, ratio = 40)
    width = img.columns
    height = img.rows

    pixels = []
    (1..width).to_a.sample(width / ratio).each do |x|
      (1..height).to_a.sample(height / ratio).each do |y|
        pixels << img.pixel_color(x - 1, y - 1)
      end
    end

    pixels
  end

  def is_dark?(file)
    img_list = Magick::ImageList.new(file)
    img = img_list.first

    sum_under = 0
    pixels = sample_pixels(img)
    pixels.each do |pixel|
      sum_under += 1 if to_gray(pixel) < 10_000
    end

    ratio_under = sum_under / pixels.length.to_f
    ratio_under >= 0.8
  end

  def take(file, opts = nil)
    `raspistill -o #{file} #{[@opts, opts].compact.join(" ")}`

    if is_dark?(file)
      puts "too under"
      FileUtils.remove_file(file, force: true)
      return
    end

    return file
  end
end

Dotenv.load

shot = Shot.new
file = "/tmp/#{Time.now.to_i}.jpg"
unless shot.take(file)
  unless shot.take(file, '-ex night')
    FileUtils.remove_file(file, force: true)
    exit 0
  end
end

caption = "captured at #{Time.now.strftime("%Y-%m-%d %H:%M")}"
facebook_api = Koala::Facebook::API.new(ENV['ACCESS_TOKEN'], ENV['SECRET'])
ret = facebook_api.put_picture(file, caption: caption)
puts "posted: #{ret}"

FileUtils.remove_file(file)
