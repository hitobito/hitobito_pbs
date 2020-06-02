# encoding: utf-8

#  Copyright (c) 2020, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Pbs::MailingListSerializer
  extend ActiveSupport::Concern

  included do
    alias_method_chain :subscribers_includes, :kantonalverband
  end

  def subscribers_includes_with_kantonalverband
    subscribers_includes_without_kantonalverband + [:kantonalverband]
  end

end
