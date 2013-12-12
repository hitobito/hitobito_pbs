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