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
          expect { perform_request }.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
        end
      end
    end

    context 'for abteilung' do
      describe_action :put, :update, id: true do
        let(:test_entry) { groups(:schekka) }
        let(:params) { { group: { bank_account: 'CH123', vkp: true, pta: false } } }

        it 'cannot change superior attributes' do
          expect { perform_request }.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
        end
      end
    end

  end
end
