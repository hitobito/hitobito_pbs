# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::QualificationsController
  extend ActiveSupport::Concern

  included do
    alias_method_chain :load_qualification_kinds, :manual
    alias_method_chain :save_entry, :manual
  end

  private

  def load_qualification_kinds_with_manual
    @qualification_kinds = load_qualification_kinds_without_manual.where(manual: true)
  end

  def save_entry_with_manual
    authorize!(:create, entry) && save_entry_without_manual
  end

end
