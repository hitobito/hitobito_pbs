# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event
  extend ActiveSupport::Concern

  included do
    class_attribute :superior_attributes, :default_contact_attrs
    self.superior_attributes = []
    self.default_contact_attrs = {
      required: [:address, :zip_code, :town, :country, :gender, :birthday, :nationality_j_s, :correspondence_language],
      hidden: [:company_name, :entry_date, :leaving_date, :grade_of_school, :title]
    }
  end
end
