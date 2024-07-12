#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.
#
# Table name: qualifications
#
#  id                     :integer          not null, primary key
#  person_id              :integer          not null
#  qualification_kind_id  :integer          not null
#  start_at               :date             not null
#  finish_at              :date
#  origin                 :string(255)
#  event_participation_id :integer          null
#
#
module Pbs::Qualification
  extend ActiveSupport::Concern

  included do
    belongs_to :event_participation, class_name: "::Event::Participation"
  end
end
