# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::Participation do
  let(:course) { events(:top_course) }

  context '#approvers' do
    it 'is empty if no application exists' do
      expect(Fabricate(:pbs_participation, event: course).approvers).to be_empty
    end

    it 'returns people that approved or rejected participation' do
      participation = Fabricate(:pbs_participation, event: course, application: Event::Application.new(priority_1: course))
      participation.application.approvals.create!(layer: 'abteilung', approved: true, approver: people(:al_schekka))
      participation.application.approvals.create!(layer: 'region', rejected: true, approver: people(:bulei))
      participation.application.approvals.create!(layer: 'kantonalverband')

      expect(participation.approvers).to have(2).items
      expect(participation.approvers).to include(people(:bulei), people(:al_schekka))
    end
  end


end
