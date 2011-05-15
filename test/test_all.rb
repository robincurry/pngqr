require File.expand_path(File.join(File.dirname(__FILE__), '../lib/pngqr'))
begin
  require 'qrscanner'
rescue LoadError
  begin
    require 'zxing'
  rescue LoadError
  end
end
require 'test/unit'
require 'tempfile'

class TestPngqr < Test::Unit::TestCase
  def test_autosize
    (0..3).each do |n|
      with_encoded_png('x'*(10**n)) do |file, encoded|
        assert_encoded_equals_decoded(file, encoded)
      end
    end
  end

  def test_static_size
    with_encoded_png('y'*10, :size => 2) do |file, encoded|
      assert_encoded_equals_decoded(file, encoded)
    end
    with_encoded_png('y'*100, :size => 20) do |file, encoded|
      assert_encoded_equals_decoded(file, encoded)
    end
    with_encoded_png('y'*1000, :size => 40) do |file, encoded|
      assert_encoded_equals_decoded(file, encoded)
    end
  end

  def test_scale
    with_encoded_png('hello, world', :scale => 5) do |file, encoded|
      assert_encoded_equals_decoded(file, encoded)
    end
  end

  def test_border
    with_encoded_png('hello, world', :border => 5) do |file, encoded|
      assert_encoded_equals_decoded(file, encoded)
    end
  end

  def test_bgcolor
    with_encoded_png('hello, world', :bgcolor => ChunkyPNG.Color(:hotpink)) do |file, encoded|
      assert_bgcolor(file, ChunkyPNG.Color(:hotpink))
      assert_encoded_equals_decoded(file, encoded)
    end
  end

  def test_color
    with_encoded_png('hello, world', :color => ChunkyPNG.Color(:lightskyblue)) do |file, encoded|
      assert_color(file, ChunkyPNG.Color(:lightskyblue))
      assert_encoded_equals_decoded(file, encoded)
    end
  end

  def test_transparency
    with_encoded_png('hello, world', :color => ChunkyPNG::Color::TRANSPARENT) do |file, encoded|
      assert_color(file, ChunkyPNG::Color::TRANSPARENT)
      assert_encoded_equals_decoded(file, encoded)
    end
  end


  protected
  def with_encoded_png(*opts)
    tempfile = Tempfile.new(self.class.to_s)
    tempfile.write(Pngqr.encode(*opts))
    tempfile.close

    begin
      yield tempfile, opts.first
    ensure
      tempfile.unlink if tempfile
    end
  end

  def assert_encoded_equals_decoded(file, expected)
    if Object.const_defined? :QrScanner
      assert_equal expected, QrScanner.decode(file.path)
    elsif Object.const_defined? :ZXing
      assert_equal expected, ZXing.decode(file)
    else
      raise Exception, "QR Decoder required. Please gem install qrscanner or zxing."
    end
  end

  def assert_bgcolor(file, color)
      assert_equal color, ChunkyPNG::Image.from_file(file)[1,1]
  end

  def assert_color(file, color)
      assert_equal color, ChunkyPNG::Image.from_file(file)[0,0]
  end

end

