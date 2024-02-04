# encoding: utf-8

#  Copyright (c) 2021, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Person::EventQueries
  extend ActiveSupport::Concern

  included do
    alias_method_chain :pending_applications, :participations_and_approvals
  end

  private

  def pending_applications_with_participations_and_approvals
    pending_applications_without_participations_and_approvals.includes(:participation, :approvals)
  end
end
