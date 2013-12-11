module Pbs
  module Export
    module CsvPeople
      module PeopleAddress
        extend ActiveSupport::Concern

        included do
          alias_method_chain :attributes, :title
        end

        def attributes_with_title
          attributes_without_title + [:title, :salutation]
        end
      end
    end
  end
end