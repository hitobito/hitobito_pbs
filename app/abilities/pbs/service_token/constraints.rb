# frozen_string_literal: true

#  Copyright (c) 2012-2021, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::ServiceToken::Constraints
  private

  def service_token_in_same_layer
    only_it_support_in_bund && super
  end

  def only_it_support_in_bund
    group && group.class == Group::Bund ? role_type?(Group::Bund::ItSupport) : true
  end

end
