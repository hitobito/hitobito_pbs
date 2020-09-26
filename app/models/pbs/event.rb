# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event
  extend ActiveSupport::Concern

  included do
    class_attribute :superior_attributes
    self.superior_attributes = []
  end

  def camp_submitted?
    !camp_submitted_at.nil?
  end
  alias :camp_submitted :camp_submitted?

  def upcoming
    dates.any? do |date|
      date.start_at.to_date.future? || (date.finish_at && date.finish_at.to_date.future?)
    end
  end
end
