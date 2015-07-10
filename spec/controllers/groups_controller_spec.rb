# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe GroupsController do

  include CrudControllerTestHelper

  let(:entry) { assigns(:group) }

  context 'as kantonsleitung' do

    let(:user) { Fabricate(Group::Kantonalverband::Kantonsleitung.name.to_sym, group: groups(:be)).person }

    context 'for kanton' do
      describe_action :put, :update, id: true do
        let(:test_entry) { groups(:be) }
        let(:params) { { group: { bank_account: 'CH123', vkp: true, pta: false } } }

        it 'cannot change superior attributes' do
          perform_request
          expect(assigns(:group).vkp).to be_falsey
        end
      end
    end

    context 'for abteilung' do
      describe_action :put, :update, id: true do
        let(:test_entry) { groups(:schekka) }
        let(:params) { { group: { bank_account: 'CH123', vkp: true, pta: false } } }

        it 'cannot change superior attributes' do
          perform_request
          expect(assigns(:group).vkp).to be_falsey
          # expect { perform_request }.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
        end
      end
    end
  end

  context '#pending_approvals' do
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
      get :pending_approvals, id: groups(:be).id
      expect(assigns(:approvals)).to have(1).item
    end

    it "denies access to listing if not authorized" do
      sign_in(people(:bulei))
      expect { get :pending_approvals, id: groups(:be).id }.to raise_error CanCan::AccessDenied
    end
  end

end
