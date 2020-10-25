# encoding: utf-8

#  Copyright (c) 2012-2020, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::ServiceToken::Constraints
  extend ActiveSupport::Concern

  included do
    alias_method_chain :service_token_core_constraints, :pbs_constraints
  end

  private

  def service_token_core_constraints_with_pbs_constraints
    only_it_support_in_bund && service_token_core_constraints_without_pbs_constraints
  end

  def only_it_support_in_bund
    group &&
    group.class == Group::Bund ? role_type?(Group::Bund::ItSupport) : true
  end

end
