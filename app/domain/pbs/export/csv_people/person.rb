# encoding: utf-8

#  Copyright (c) 2012-2013, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs
  module Export
    module CsvPeople
      module Person
        extend ActiveSupport::Concern

        included do
          alias_method_chain :initialize, :salutation
        end

        def initialize_with_salutation(person)
          initialize_without_salutation(person)
          self[:salutation] = person.salutation_value
          self[:pbs_number] = person.pbs_number
        end
      end
    end
  end
end