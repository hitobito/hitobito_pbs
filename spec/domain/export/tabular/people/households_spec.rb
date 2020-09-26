# encoding: utf-8
#  Copyright (c) 2012-2018, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Pbs::Export::Tabular::People::HouseholdsFull do

  let(:leader) { people(:top_leader) }
  let(:member) { people(:bottom_member) }

  def households(list = [])
    Pbs::Export::Tabular::People::HouseholdsFull.new(list)
  end

  context 'header' do
    it 'includes name, address attributes and layer group columns' do
      expect(households.attributes).to eq [:name, :address, :zip_code, :town,
                                           :country, :layer_group, :correspondence_language,
                                           :prefers_digital_correspondence, :kantonalverband_id,
                                           :id, :layer_group_id, :company_name, :company]
    end
  end

end
