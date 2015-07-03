# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::Course
  extend ActiveSupport::Concern

  included do
    LANGUAGES = %w(de fr it en)

    LANGUAGES.each { |lang| used_attributes << "language_#{lang}".to_sym }
    used_attributes << :express_fee

    before_save :set_requires_approval
  end


  private

  def set_requires_approval
    self.requires_approval =
      requires_approval_abteilung? ||
      requires_approval_region? ||
      requires_approval_kantonalverband? ||
      requires_approval_bund?

    true
  end

end
