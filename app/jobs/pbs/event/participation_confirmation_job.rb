# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ParticipationConfirmationJob
  extend ActiveSupport::Concern

  included do
    alias_method_chain :send_approval, :noop
  end

  def send_approval_with_noop; end
end
