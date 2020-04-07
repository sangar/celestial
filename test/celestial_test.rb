require "test_helper"

class CelestialTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Celestial::VERSION
  end

  def test_can_get_data_by_search
    data = Celestial.for(latitude: 59.9128627, longitude: 10.7434443)

    assert_equal 8, data.count
  end
end
