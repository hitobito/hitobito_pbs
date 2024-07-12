# frozen_string_literal: true

#  Copyright (c) 2022, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::MailingList
  extend ActiveSupport::Concern

  included do
    validate :assert_layer_suffix

    private

    def assert_layer_suffix
      return unless mail_name_changed?
      return if mail_name.blank?
      return if layer_shortname.empty?

      unless mail_name.to_s.downcase.end_with?("." + layer_shortname)
        errors.add(:mail_name, :must_end_with_layer_suffix, suffix: "." + layer_shortname)
      end
    end

    def layer_shortname
      group.layer_group.pbs_shortname.to_s.downcase
    end
  end
end
