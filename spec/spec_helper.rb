#  Copyright (c) 2012-2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

ENV["RAILS_STRUCTURED_ADDRESSES"] = "1"
ENV["RAILS_ADDRESS_MIGRATION"] = "0"

load File.expand_path("../app_root.rb", __dir__)
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require File.join(ENV.fetch("APP_ROOT", nil), "spec", "spec_helper.rb")

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[HitobitoPbs::Wagon.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

RSpec.configure do |config|
  config.fixture_paths = [File.expand_path("../fixtures", __FILE__)]
end
