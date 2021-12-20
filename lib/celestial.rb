require "celestial/version"
require "celestial/sun"
require "date"

module Celestial
  class << self
    def for(options)
      options = { date: DateTime.now }.merge(options)

      latitude, longitude = options[:latitude], options[:longitude]

      date = options[:date]

      y_sunrise = Sun.calculate(date - 1, latitude, longitude, :sunrise, 90.8333)
      y_sunset  = Sun.calculate(date - 1, latitude, longitude, :sunset, 90.8333)

      sunrise = Sun.calculate(date, latitude, longitude, :sunrise, 90.8333)
      sunset  = Sun.calculate(date, latitude, longitude, :sunset, 90.8333)

      y_duration = y_sunset.strftime('%s').to_i - y_sunrise.strftime('%s').to_i
      duration = sunset.strftime('%s').to_i - sunrise.strftime('%s').to_i

      noon = sunrise.strftime('%s').to_i + (duration / 2)

      if (y_duration > duration)
        diff = Time.at(y_duration - duration).utc.strftime("-%M:%S")
      else
        diff = Time.at(duration - y_duration).utc.strftime("+%M:%S")
      end

      mspn = Sun.midnight_sun_polar_night(date, latitude, longitude, :sunrise, 90.8333)

      {
        sunrise: sunrise,
        sunset: sunset,
        length: Time.at(duration).utc.strftime("%T"),
        midnight_sun: mspn.eql?(:midnight_sun),
        polar_night: mspn.eql?(:polar_night),
        difference: diff,
        noon: Time.at(noon).to_datetime,
        civil: {
          sunrise: Sun.calculate(date, latitude, longitude, :sunrise, 96),
          sunset: Sun.calculate(date, latitude, longitude, :sunset, 96)
        },
        nautical: {
          sunrise: Sun.calculate(date, latitude, longitude, :sunrise, 102),
          sunset: Sun.calculate(date, latitude, longitude, :sunset, 102)
        },
        astronomical: {
          sunrise: Sun.calculate(date, latitude, longitude, :sunrise, 108),
          sunset: Sun.calculate(date, latitude, longitude, :sunset, 108)
        }
      }
    end
  end
end
