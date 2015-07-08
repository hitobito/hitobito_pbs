# encoding: utf-8
#
#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::ApplicationDecorator
  extend ActiveSupport::Concern

  included do
    alias_method_chain :used?, :check
  end

  def used_with_check?(attr)
    if %w(training_days express_fee).include?(attr.to_s)
      if current_user.roles.any? { |role| role.class == Group::Bund::AssistenzAusbildung }
        used_without_check?(attr) { yield }
      end
    else
      used_without_check?(attr) { yield }
    end
  end

end
