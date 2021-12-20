module Celestial
  class Sun
    class << self
      def calculate(date, latitude, longitude, sunrise, zenith)
        doy              = day_of_the_year(date)
        lng_hour, t      = convert_lng_to_hour_value(longitude, doy, sunrise)
        m                = calculate_suns_mean_anomaly(t)
        l                = calculate_suns_true_longitude(m)
        ra               = calculate_suns_right_ascension(l)
        ra               = right_ascension_value_needs_to_be_in_same_quadrant(l, ra)
        ra               = right_ascension_value_needs_to_be_converted_into_hours(ra)
        sin_dec, cos_dec = calculate_the_suns_declination(l)
        cos_h            = calculate_the_suns_local_hour_angle(zenith, latitude, sin_dec, cos_dec)
        h                = finish_calculating_h_and_convert_into_hours(cos_h, sunrise)
        lmt              = calculate_local_mean_time_of(h, ra, t)
        utc_time         = adjust_back_to_utc(lmt, lng_hour)
        result           = convert_utc_time_to_local_time_zone_of_lat_lng(date, utc_time)
        result
      end

      def midnight_sun_polar_night(date, latitude, longitude, sunrise, zenith)
        doy              = day_of_the_year(date)
        lng_hour, t      = convert_lng_to_hour_value(longitude, doy, sunrise)
        m                = calculate_suns_mean_anomaly(t)
        l                = calculate_suns_true_longitude(m)
        ra               = calculate_suns_right_ascension(l)
        ra               = right_ascension_value_needs_to_be_in_same_quadrant(l, ra)
        ra               = right_ascension_value_needs_to_be_converted_into_hours(ra)
        sin_dec, cos_dec = calculate_the_suns_declination(l)
        cos_h            = calculate_the_suns_local_hour_angle(zenith, latitude, sin_dec, cos_dec)

        if (cos_h >=  1.0)
          :polar_night
        elsif (cos_h <= -1.0)
          :midnight_sun
        else
          :none
        end
      end

      #
      # Common
      def degrees_as_radians(degrees)
        radians = Math::PI / 180.0
        degrees * radians
      end

      def rads_as_degrees(radians)
        degree = 180.0 / Math::PI
        radians * degree
      end

      def put_in_range(number, lower, upper, adjuster)
        if number > upper
          number -= adjuster
        elsif number < lower
          number += adjuster
        else
          number
        end
      end


      # 1. first calculate the day of the year
      def day_of_the_year(date)
        date.yday
      end

      # 2. convert the longitude to hour value and calculate an approximate time
      def convert_lng_to_hour_value(longitude, doy, rise_or_set)
        lng_hour = longitude / 15.0

        if rise_or_set == :sunrise
          t = doy + ((6.0 - lng_hour) / 24.0)
        end

        if rise_or_set == :sunset
          t = doy + ((18.0 - lng_hour) / 24.0)
        end

        [lng_hour, t]
      end

      # 3. calculate the Sun's mean anomaly
      def calculate_suns_mean_anomaly(t)
        (0.9856 * t) - 3.289
      end

      # 4. calculate the Sun's true longitude
      def calculate_suns_true_longitude(m)
        m_rad = degrees_as_radians(m)

        true_long = m + (1.916 * Math.sin(m_rad)) + (0.020 * Math.sin(2 * m_rad)) + 282.634
        put_in_range(true_long, 0, 360, 360)
      end

      # 5a. calculate the Sun's right ascension
      def calculate_suns_right_ascension(l)
        tan_l = Math.tan(degrees_as_radians(l))
        ra = rads_as_degrees(Math.atan(0.91764 * tan_l))
        put_in_range(ra, 0, 360, 360)
      end

      # 5b. right ascension value needs to be in the same quadrant as L
      def right_ascension_value_needs_to_be_in_same_quadrant(l, ra)
        l_quadrant  = (( l/90).floor) * 90
        ra_quadrant = ((ra/90).floor) * 90
        ra + (l_quadrant - ra_quadrant)
      end

      # 5c. right ascension value needs to be converted into hours
      def right_ascension_value_needs_to_be_converted_into_hours(ra)
        ra / 15
      end

      # 6. calculate the Sun's declination
      def calculate_the_suns_declination(l)
        l_rad = degrees_as_radians(l)
        sin_dec = 0.39782 * Math.sin(l_rad)
        cos_dec = Math.cos(Math.asin(sin_dec))

        [sin_dec, cos_dec]
      end

      # 7a. calculate the Sun's local hour angle
      def calculate_the_suns_local_hour_angle(zenith, latitude, sin_dec, cos_dec)
        z_rad = degrees_as_radians(zenith)

        lat_rag = degrees_as_radians(latitude)

        top = Math.cos(z_rad) - (sin_dec * Math.sin(lat_rag))
        bottom = cos_dec * Math.cos(lat_rag)
        cos_h = top / bottom

        if (cos_h >  1.0)
          # the sun never rises on this location (on the specified date)
          return 1.0
        end
        if (cos_h < -1.0)
          # the sun never sets on this location (on the specified date)
          return -1.0
        end

        cos_h
      end

      # 7b. finish calculating H and convert into hours
      def finish_calculating_h_and_convert_into_hours(cos_h, rise_or_set)
        acos_h = Math.acos(cos_h)
        acos_h_deg = rads_as_degrees(acos_h)

        if rise_or_set == :sunrise
          h = 360.0 - acos_h_deg
        end

        if rise_or_set == :sunset
          h = acos_h_deg
        end

        h / 15.0
      end

      # 8. calculate local mean time of rising/setting
      def calculate_local_mean_time_of(h, ra, t)
        h + ra - (0.06571 * t) - 6.622
      end

      # 9. adjust back to UTC
      def adjust_back_to_utc(lmt, lng_hour)
        put_in_range(lmt - lng_hour, 0, 23, 24)
      end

      # 10. convert UTC value to local time zone of latitude/longitude
      def convert_utc_time_to_local_time_zone_of_lat_lng(date, utc_time)
        time = utc_time + date.zone.to_i

        hour, m = time.to_s.split('.')
        minute = (".#{m}".to_f * 60.0)
        second = (".#{minute.to_s.split('.')[1]}".to_f * 60.0)

        hour = put_in_range(hour.to_i, 0, 23, 24)
        minute = minute.truncate
        second = second.truncate

        return DateTime.new(date.year, date.month, date.mday, hour, minute, second, date.zone)
      end
    end
  end
end