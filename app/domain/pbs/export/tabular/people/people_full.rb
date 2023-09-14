# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs
  module Export
    module Tabular
      module People
        module PeopleFull
          extend ActiveSupport::Concern

          included do
            alias_method_chain :person_attributes, :pbs
          end

          def person_attributes_with_pbs
            person_attributes_without_pbs + [:id, :layer_group_id, :pbs_number, 
                                             :has_siblings_in_layer]
          end

          def initialize(list, group)
            super(list)
            @group = group
          end

          private

          def row_for(entry, format = nil)
            row_class.new(entry, format, @group)
          end

        end
      end
    end
  end
end
