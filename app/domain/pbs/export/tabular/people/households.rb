# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs
  module Export
    module Tabular
      module People
        module Households
          extend ActiveSupport::Concern

          included do
            alias_method_chain :initialize, :kv
            alias_method_chain :person_attributes, :title
          end

          def initialize_with_kv(list) #TODO is this method needed?
            if list.respond_to?(:klass)
              incl = list.klass < Person ? :kantonalverband : { person: :kantonalverband }
              initialize_without_kv(list.includes(incl))
            else
              initialize_without_kv(list)
            end
          end

          def person_attributes_with_title
            person_attributes_without_title +
            [:correspondence_language, :kantonalverband_id,
             :id, :layer_group_id, :company_name, :company]
          end
        end
      end
    end
  end
end
