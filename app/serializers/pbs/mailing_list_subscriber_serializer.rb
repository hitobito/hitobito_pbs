# encoding: utf-8

#  Copyright (c) 2020, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Pbs::MailingListSubscriberSerializer
  extend ActiveSupport::Concern

  included do
    schema do
      property :correspondence_language, item.correspondence_language
      property :kantonalverband_short_name, item.kantonalverband.short_name
    end
  end
end
