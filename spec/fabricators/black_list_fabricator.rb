#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# == Schema Information
#
# Table name: black_lists
#
#  id                     :integer          not null, primary key
#  first_name             :string
#  last_name              :string
#  pbs_number             :string
#  email                  :string
#  phone_number           :string
#  reference_name         :string
#  reference_phone_number :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

Fabricator(:black_list) do
  first_name             { Faker::Name.first_name }
  last_name              { Faker::Name.last_name }
  email                  { Faker::Internet.email }
  pbs_number             { Faker::Number.number(digits: 9).to_s.scan(/\d{3}/).join('-') }
  phone_number           { Faker::PhoneNumber.phone_number }
  reference_name         { Faker::Name.name }
  reference_phone_number { Faker::PhoneNumber.phone_number }
end
