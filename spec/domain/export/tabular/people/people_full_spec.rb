# frozen_string_literal: true

#  Copyright (c) 2012-2021, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require "spec_helper"

describe Export::Tabular::People::PeopleFull do
  let(:person) { people(:bulei) }
  let(:list) { [person] }
  let(:people_list) { Export::Tabular::People::PeopleFull.new(list) }

  subject { people_list }

  context 'attributes include' do
    it 'id' do
      expect(subject.attributes).to include(:id)
    end

    it 'layer-group id' do
      expect(subject.attributes).to include(:layer_group_id)
    end

    it 'layer-group (name)' do
      expect(subject.attributes).to include(:layer_group)
    end

    it 'tags' do
      expect(subject.attributes).to include(:tags)
    end

    it 'prefers_digital_correspondence' do
      expect(subject.attributes).to include(:prefers_digital_correspondence)
    end

    it 'kantonalverband_id' do
      expect(subject.attributes).to include(:kantonalverband_id)
    end

    it 'pbs_number' do
      expect(subject.attributes).to include(:pbs_number)
    end
  end

end
