#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs
  module Export
    module Tabular
      module People
        module PeopleAddress
          extend ActiveSupport::Concern

          def initialize(list, ability = nil)
            if list.respond_to?(:klass) && list.klass < Person
              super(list.includes(:kantonalverband), ability)
            elsif list.respond_to?(:klass) && list.klass < Event::Participation
              preloaded_list = list.tap do |l|
                ::Event::Participation::PreloadParticipations.preload(l, participant: :kantonalverband)
              end
              super(preloaded_list, ability)
            else
              super
            end
          end

          def person_attributes
            super +
              [:title, :salutation, :language, :prefers_digital_correspondence,
                :kantonalverband_id, :id, :layer_group_id]
          end
        end
      end
    end
  end
end
