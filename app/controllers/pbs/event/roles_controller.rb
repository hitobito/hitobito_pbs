# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::RolesController
  extend ActiveSupport::Concern

  included do
    alias_method_chain :build_entry, :state
  end

  private

  def build_entry_with_state
    role = build_entry_without_state
    role.participation.state ||= 'assigned'
    role
  end

end
