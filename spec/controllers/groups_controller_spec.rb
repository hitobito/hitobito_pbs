# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe GroupsController do

  include CrudControllerTestHelper

  let(:entry) { assigns(:group) }

  context 'PUT update cantons' do

    let(:user) { Fabricate(Group::Kantonalverband::Kantonsleitung.name.to_sym, group: groups(:be)).person }

    describe_action :put, :update, id: true do
      let(:test_entry) { groups(:be) }

      context 'with multiple cantons' do
        let(:params) { { group: { cantons: %w(be bs zh) } } }

        it 'updates cantons' do
          test_entry.update!(cantons: %w(be ge))
          expect { perform_request }.to change { KantonalverbandCanton.count }.by(1)
          expect(assigns(:group).cantons).to eq %w(be bs zh)
        end
      end

      context 'with no cantons' do
        let(:params) { { group: { cantons: [''] } } }

        it 'removes cantons' do
          test_entry.update!(cantons: %w(be ge))
          expect { perform_request }.to change { KantonalverbandCanton.count }.by(-2)
          expect(assigns(:group).cantons).to eq []
        end
      end
    end

  end

  context 'update superior attributes as kantonsleitung' do

    let(:user) { Fabricate(Group::Kantonalverband::Kantonsleitung.name.to_sym, group: groups(:be)).person }

    context 'for kanton' do
      describe_action :put, :update, id: true do
        let(:test_entry) { groups(:be) }
        let(:params) { { group: { bank_account: 'CH123', vkp: true, pta: false } } }

        it 'cannot change' do
          perform_request
          expect(assigns(:group).vkp).to be_falsey
        end
      end
    end

    context 'for abteilung' do
      describe_action :put, :update, id: true do
        let(:test_entry) { groups(:schekka) }
        let(:params) { { group: { bank_account: 'CH123', vkp: true, pta: false } } }

        it 'cannot change' do
          perform_request
          expect(assigns(:group).vkp).to be_falsey
        end
      end
    end
  end

  context '#pending_approvals' do
    let(:course) { events(:top_course) }
    let(:person) { people(:child) }
    let(:participation) { Fabricate(:pbs_participation, event: course, person: person) }
    let(:other_participation) { event_participations(:top_participant) }

    def create_application_and_approval(participation)
      application = participation.create_application(priority_1: course)
      application.approvals.create!(layer: 'kantonalverband')
    end

    before do
      person.update(primary_group: groups(:pegasus))
      people(:al_schekka).update(primary_group: groups(:be))
      other_participation.update(created_at: 1.year.ago)
      create_application_and_approval(participation)
      @other_approval = create_application_and_approval(other_participation)
    end

    it "lists pending approvals for layers oldest at the top" do
      Fabricate(Group::Kantonalverband::Kantonsleitung.name, person: people(:bulei), group: groups(:be))
      sign_in(people(:bulei))
      get :pending_approvals, id: groups(:be).id
      expect(assigns(:approvals)).to have(2).item
      expect(assigns(:approvals).first).to eq @other_approval
    end

    it "denies access to listing if not authorized" do
      sign_in(people(:bulei))
      expect { get :pending_approvals, id: groups(:be).id }.to raise_error CanCan::AccessDenied
    end
  end

end
