module Pbs
  module Export
    module CsvPeople
      module PeopleFull
        extend ActiveSupport::Concern

        included do
          alias_method_chain :attributes, :pbs
        end

        def attributes_with_pbs
          attributes_without_pbs + [:pbs_number]
        end
      end
    end
  end
end