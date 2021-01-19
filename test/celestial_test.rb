require "test_helper"

class CelestialTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Celestial::VERSION
  end

  # rake test TESTOPTS="--name=test_data_for_oslo -v"
  def test_data_for_oslo
    data = Celestial.for(
      latitude: 59.9128627,
      longitude: 10.7434443,
      date: DateTime.parse("2021-01-19T17:07:59+01:00")
    )

    assert_equal "06:59:56", data[:length]
    assert_equal "+04:05", data[:difference]
    assert_equal false, data[:midnight_sun]
    assert_equal false, data[:polar_night]
  end

  def test_data_for_cape_town
    data = Celestial.for(
      latitude: -33.920326,
      longitude: 18.431069,
      date: DateTime.parse("2021-01-19T17:07:59+01:00")
    )

    assert_equal "14:04:35", data[:length]
    assert_equal "-01:19", data[:difference]
    assert_equal false, data[:midnight_sun]
    assert_equal false, data[:polar_night]
  end

  def test_data_for_king_george_island
    data = Celestial.for(
      latitude: -62.085292,
      longitude: -58.391244,
      date: DateTime.parse("2021-01-19T17:07:59+01:00")
    )

    assert_equal "18:16:18", data[:length]
    assert_equal "-05:19", data[:difference]
    assert_equal false, data[:midnight_sun]
    assert_equal false, data[:polar_night]
  end

  def test_data_for_tromso_summer
    data = Celestial.for(
      latitude: 69.649176,
      longitude: 18.955362,
      date: DateTime.parse("2020-06-21T17:07:59+01:00")
    )

    assert_equal "00:00:06", data[:length]
    assert_equal "+00:00", data[:difference]
    assert_equal true, data[:midnight_sun]
    assert_equal false, data[:polar_night]
  end

  def test_data_for_tromso_winter
    data = Celestial.for(
      latitude: 69.649176,
      longitude: 18.955362,
      date: DateTime.parse("2020-12-21T17:07:59+01:00")
    )

    assert_equal "00:00:15", data[:length]
    assert_equal "+00:00", data[:difference]
    assert_equal false, data[:midnight_sun]
    assert_equal true, data[:polar_night]
  end

  def test_data_for_longyearbyen
    data = Celestial.for(
      latitude: 78.223735,
      longitude: 15.641449,
      date: DateTime.parse("2021-03-15T17:07:59+01:00")
    )

    assert_equal "11:09:13", data[:length]
    assert_equal "+15:18", data[:difference]
    assert_equal false, data[:midnight_sun]
    assert_equal false, data[:polar_night]
  end
end
