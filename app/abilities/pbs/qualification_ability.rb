# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::QualificationAbility
  extend ActiveSupport::Concern

  included do
    alias_method_chain :in_course_layer, :manual
    alias_method_chain :in_course_layer_or_below, :manual
  end

  def in_course_layer_with_manual
    manual_kind? && in_course_layer_without_manual
  end

  def in_course_layer_or_below_with_manual
    manual_kind? && in_course_layer_or_below_without_manual
  end

  private

  def manual_kind?
    kind = subject.qualification_kind
    kind.nil? || kind.manual?
  end

end
