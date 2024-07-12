# frozen_string_literal: true

#  Copyright (c) 2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

namespace :geoblocking do
  desc "Export list of blocked countries"
  task :nginx do # rubocop:disable Rails/RakeEnvironment
    # this could be a list of country-code, but this should
    # be easier to maintain
    countries = {
      IN: "India",
      HK: "Hong Kong",
      SN: "Senegal",
      TR: "Turkey",
      CR: "Costa Rica",
      IS: "Iceland",
      LA: "Lao People's Democratic Republic (the)",
      ZA: "South Africa",
      VN: "Viet Nam",
      JP: "Japan",
      MX: "Mexico",
      LB: "Lebanon",
      SG: "Singapore",
      AU: "Australia",
      EC: "Ecuador",
      RU: "Russian Federation (the)",
      BR: "Brazil",
      VE: "Venezuela (Bolivarian Republic of)"
    }.keys

    country_block_config = countries.map do |country|
      "  #{country} no;"
    end.join("\n")

    puts <<~NGINX
      map $geoip2_data_country_iso_code $allowed_country {
        default yes;

      #{country_block_config}
      }
    NGINX
  end
end
