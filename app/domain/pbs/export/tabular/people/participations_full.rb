# encoding: utf-8

#  Copyright (c) 2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs
  module Export
    module Tabular
      module People
        module ParticipationsFull
          extend ActiveSupport::Concern

          included do
            alias_method_chain :build_attribute_labels, :pbs
          end

          def build_attribute_labels_with_pbs
            build_attribute_labels_without_pbs.tap do |labels|
              labels[:bsv_days] = ::Event::Participation.human_attribute_name(:bsv_days)
            end
          end
        end
      end
    end
  end
end
