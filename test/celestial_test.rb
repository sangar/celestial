require "test_helper"

class CelestialTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Celestial::VERSION
  end

  def test_can_get_data_by_search
    datas = []
    31.times do |i|
      data = Celestial.for(
        latitude: 59.9128627,
        longitude: 10.7434443,
        date: DateTime.new(2020, 1, (1 + i), 0, 0, 0, '+01:00')
      )
      datas << data
    end

    puts "datas:"
    datas.each do |data|
      puts "#{data[:sunrise].day}, sunrise: #{data[:sunrise].strftime("%T")}, sunset: #{data[:sunset].strftime("%T")}, length: #{data[:length]}, difference: #{data[:difference]}"
    end

    assert_equal 9, datas.first.count
  end
end
