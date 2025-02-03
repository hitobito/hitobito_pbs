# == Schema Information
#
# Table name: event_kinds
#
#  id          :integer          not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  deleted_at  :datetime
#  minimum_age :integer
#

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.
Fabricator(:pbs_course_kind, class_name: "Event::Course::Kind") do
  label { Faker::Company.bs }
  general_information { Faker::Lorem.sentence }
  confirmation_name "basiskurs"
  can_have_confirmations true
  event_kind_qualification_kinds {
    [Event::KindQualificationKind.new(qualification_kind: Fabricate(:qualification_kind),
      category: :qualification,
      role: :participant)]
  }
end
