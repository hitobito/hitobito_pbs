# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ParticipationContactData
  extend ActiveSupport::Concern

  included do
    Event::ParticipationContactData.contact_attrs << :title << :salutation <<
     :correspondence_language << :grade_of_school << :entry_date << :leaving_date

    delegate(*Event::ParticipationContactData.contact_attrs, to: :person)
  end

end
