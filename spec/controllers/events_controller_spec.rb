# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe EventsController do

  include CrudControllerTestHelper

  let(:entry) { assigns(:group) }

  context '#list_completed_approvals' do
    let(:course) { events(:top_course) }
    let(:person) { people(:child) }
    let(:participation) { Fabricate(:event_participation, event: course, person: person) }
    let!(:application) { participation.create_application(priority_1: course)}

    before do
      person.update(primary_group: groups(:pegasus))
      application.approvals.create!(layer: 'kantonalverband', approved: true)
    end

    it "lists completed approvals for course" do
      sign_in(people(:bulei))
      get :list_completed_approvals, group_id: groups(:be).id, id: course.id
      expect(assigns(:approvals)).to have(1).item
    end
    it "denies access" do
      sign_in(people(:child))
      expect { get :show, group_id: groups(:be).id, id: course.id }.not_to raise_error
    end

    it "denies access" do
      sign_in(people(:child))


      expect { get :list_completed_approvals, group_id: groups(:be).id, id: course.id }.to raise_error CanCan::AccessDenied
    end
  end

end
