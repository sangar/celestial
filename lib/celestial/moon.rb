module Celestial
  class Moon
    class << self
      def for(options)
        options = { date: DateTime.now }.merge(options)

        lunation = calculate(options[:date])
        phase_text = phase_text(lunation)
        phase_text_format = phase_text.split("_").each {|word| word.capitalize! }.join(" ")

        curve = Math.sin(lunation * Math::PI)
        percent = (curve * 100).round(1)

        {
          datetime: options[:date],
          lunation: lunation,
          phase: phase_text,
          phase_text: phase_text_format,
          curve: curve,
          percent: percent,
          next_full: next_full(options[:date])
        }
      end

      def next_full(date)
        time = date.to_time

        30.times do |i|
          24.times do |j|
            new_time = time + (i * 24 * 3600) + (j * 3600)
            new_date = DateTime.parse(new_time.to_s)

            lunation = calculate(new_date).round(5)
            curve = Math.sin(lunation * Math::PI)
            percent = (curve * 100).round(2)

            if percent == 100.0
              return new_date
            end
          end
        end
      end

      def get_frac(fr)
        fr - fr.floor
      end

      def phase_text(phase)
        if (phase <= 0.0625 || phase > 0.9375)
          "new_moon"
        elsif (phase <= 0.1875)
          "waxing_crescent"
        elsif (phase <= 0.3125)
          "first_quarter"
        elsif (phase <= 0.4375)
          "waxing_gibbous"
        elsif (phase <= 0.5625)
          "full_moon"
        elsif (phase <= 0.6875)
          "waning_gibbous"
        elsif (phase <= 0.8125)
          "last_quarter"
        elsif (phase <= 0.9375)
          "waning_crescent"
        end
      end

      def calculate(date)
        thisJD = date.ajd.to_f
        year = date.year
        degToRad = Math::PI / 180

      # k0, t, t2, t3, j0, f0, m0, m1, b1, oldJ
        k0 = ((year - 1900) * 12.3685).floor
        t = (year - 1899.5) / 100
        t2 = t * t
        t3 = t * t * t
        j0 = 2415020 + 29 * k0
        f0 = 0.0001178 * t2 - 0.000000155 * t3 + (0.75933 + 0.53058868 * k0) - (0.000837 * t + 0.000335 * t2)
        m0 = 360 * get_frac(k0 * 0.08084821133) + 359.2242 - 0.0000333 * t2 - 0.00000347 * t3
        m1 = 360 * get_frac(k0 * 0.07171366128) + 306.0253 + 0.0107306 * t2 + 0.00001236 * t3
        b1 = 360 * get_frac(k0 * 0.08519585128) + 21.2964 - (0.0016528 * t2) - (0.00000239 * t3)
        phase = 0.0
        jday = 0.0

        while jday < thisJD do
          f = f0 + 1.530588 * phase
          m5 = (m0 + phase * 29.10535608) * degToRad
          m6 = (m1 + phase * 385.81691806) * degToRad
          b6 = (b1 + phase * 390.67050646) * degToRad
          f -= 0.4068 * Math.sin(m6) + (0.1734 - 0.000393 * t) * Math.sin(m5)
          f += 0.0161 * Math.sin(2 * m6) + 0.0104 * Math.sin(2 * b6)
          f -= 0.0074 * Math.sin(m5 - m6) - 0.0051 * Math.sin(m5 + m6)
          f += 0.0021 * Math.sin(2 * m5) + 0.0010 * Math.sin(2 * b6 - m6)
          f += 0.5 / 1440
          oldJ = jday
          jday = j0 + 28.0 * phase + f
          phase += 1.0
        end

        # 29.53059 days per lunar month
        (thisJD - oldJ) / 29.5305888531
      end
    end
  end
end