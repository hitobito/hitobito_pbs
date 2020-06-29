# encoding: utf-8

#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Pbs::EventParticipationSerializer
  extend ActiveSupport::Concern
  
  included do
    extension(:attrs) do |_|
      property(:phone_numbers, item.person.phone_numbers.select(&:public).map do |number| 
        { 
          number: number.number,
          translated_label: number.translated_label
        }
      end)
    end
  end
end
