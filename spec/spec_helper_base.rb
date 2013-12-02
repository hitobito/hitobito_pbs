# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito_jubla and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_jubla.

# Configure Rails Environment
require File.expand_path('../../app_root', __FILE__)
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require File.join(ENV["APP_ROOT"], 'spec', 'spec_helper.rb')

RSpec.configure do |config|
  config.fixture_path = File.expand_path("../fixtures", __FILE__)
end
