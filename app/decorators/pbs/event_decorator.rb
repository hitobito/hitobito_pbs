# encoding: utf-8

#  Copyright (c) 2012-2019, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Pbs::EventDecorator
  extend ActiveSupport::Concern


  included do
    decorates_association :leader
    decorates_association :abteilungsleitung
    decorates_association :coach
    decorates_association :advisor_mountain_security
    decorates_association :advisor_snow_security
    decorates_association :advisor_water_security
  end

  def can_have_confirmations?
    course_kind? && kind.can_have_confirmations?
  end
end
