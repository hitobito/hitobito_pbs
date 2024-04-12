# frozen_string_literal: true

#  Copyright (c) 2024,  Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe EventResource, type: :resource do
  let!(:camp) { events(:tsueri_supercamp) }
  let!(:course) { events(:top_course) }

  before do
    params[:include] = 'advisor'
    course.update!(advisor_id: person.id)
  end

  describe 'advisor' do
    it 'is null for camps' do
      params[:filter] = { id: { eq: camp.id } }
      render

      advisor_data = d[0].sideload(:advisor)

      expect(jsonapi_data).to have(1).item
      expect(jsonapi_data[0].id).to eq camp.id
      expect(advisor_data).to be_nil
    end

    it 'works for courses' do
      params[:filter] = { id: { eq: course.id } }
      render

      advisor_data = d[0].sideload(:advisor)

      expect(jsonapi_data).to have(1).item
      expect(jsonapi_data[0].id).to eq course.id
      expect(advisor_data.id).to eq person.id
    end
  end
end
