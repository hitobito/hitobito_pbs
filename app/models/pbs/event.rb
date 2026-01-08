#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event
  extend ActiveSupport::Concern

  J_S_KINDS_DATA_SHARING_ACCEPTANCE = %w[j_s_child j_s_youth j_s_mixed].freeze

  included do
    class_attribute :superior_attributes
    self.superior_attributes = []

    # dummy accessors for event_resource (only courses do have advisor)
    attr_accessor :advisor_id, :advisor

    private

    # Super cannot be called directly since the module redefines the original method
    alias :original_attributes_for_duplicate :attributes_for_duplicate

    def attributes_for_duplicate
      original_attributes_for_duplicate.excluding("lft", "rgt", "depth", "children_count", "parent_id")
    end
  end

  def camp_submitted?
    !camp_submitted_at.nil?
  end
  alias_method :camp_submitted, :camp_submitted?

  def upcoming
    dates.any? do |date|
      date.start_at.to_date.future? || date.finish_at&.to_date&.future?
    end
  end

  def j_s_data_sharing_acceptance_required?
    [Event::Camp.name, Event::Campy.name, Event::Course.name].include?(type) &&
      J_S_KINDS_DATA_SHARING_ACCEPTANCE.include?(j_s_kind)
  end
end
