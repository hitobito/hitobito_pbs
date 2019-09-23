# encoding: utf-8

#  Copyright (c) 2012-2017, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Export::Tabular::People::PeopleFull do

  let(:person) { people(:bulei) }
  let(:list) { [person] }
  let(:people_list) { Export::Tabular::People::PeopleFull.new(list) }

  subject { people_list }

  let(:full_attributes) do
    [:first_name, :last_name, :company_name, :nickname,
     :company, :email, :address, :zip_code, :town, :country,
     :gender, :birthday, :additional_information, :salutation, :title, :entry_date, :leaving_date, 
     :brother_and_sisters, :layer_group,
     :roles, :tags, :id, :layer_group_id]
  end

  its(:attributes) { should eq full_attributes }

end
