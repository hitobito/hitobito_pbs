# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe EventApprovalsController do

  let(:course) { events(:top_course) }
  let(:person) { people(:child) }
  let(:participation) { Fabricate(:event_participation, event: course, person: person) }
  let!(:application) { participation.create_application(priority_1: course)}

  before do
    person.update(primary_group: groups(:pegasus))
    application.approvals.create!(layer: 'kantonalverband')
  end

  it "lists pending approvals for layer" do
    Fabricate(Group::Kantonalverband::Kantonsleitung.name, person: people(:bulei), group: groups(:be))
    sign_in(people(:bulei))
    get :layer, id: groups(:be).id
    expect(assigns(:entries)).to have(1).item
  end

  it "denies access to listing if not authorized" do
    sign_in(people(:bulei))
    expect { get :layer, id: groups(:be).id }.to raise_error CanCan::AccessDenied
  end
end
