# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs
  module Export
    module Csv
      module People
        module PeopleAddress
          extend ActiveSupport::Concern

          included do
            alias_method_chain :person_attributes, :title
          end

          def person_attributes_with_title
            person_attributes_without_title + [:title, :salutation, :correspondence_language]
          end
        end
      end
    end
  end
end
