# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe RolesController do

  let(:group)  { groups(:bund) }
  let(:person) { people(:al_schekka) }
  let(:role)   { assigns(:role).model }

  let(:role_defaults) do
    { group_id: group.id,
      person_id: person.id,
      type: Group::Bund::MitarbeiterGs.sti_name }
  end

  before { sign_in(people(:bulei)) }

  describe 'GET #edit' do
    context 'deleted role' do
      it 'renders template' do
        role = roles(:al_schekka)
        role.update_attributes!(created_at: 100.days.ago, deleted_at: 5.days.ago)
        get :edit, group_id: role.group_id, id: role.id
        should render_template('edit')
      end
    end
  end

  describe 'POST #create' do

    context 'with valid params' do
      let(:role_params) do
        role_defaults.merge(created_at: Date.new(2014, 3, 4),
                            deleted_at: Date.new(2014, 3, 5))
      end

      it 'creates role with dates set' do
        expect { post :create, group_id: group.id, role: role_params }.to change { Role.with_deleted.count }.by(1)

        role.created_at.to_date.should eq Date.new(2014, 3, 4)
        role.deleted_at.to_date.should eq Date.new(2014, 3, 5)
        should redirect_to(group_people_path(group.id))
      end

      it 'redirects' do
        expect { post :create, group_id: group.id, role: role_params }.to change { Role.with_deleted.count }.by(1)
        flash[:notice].should eq 'Rolle <i>Mitarbeiter GS</i> für <i>AL Schekka</i> in <i>Pfadibewegung Schweiz</i> wurde erfolgreich erstellt.'
        should redirect_to(group_people_path(group.id))
      end
    end

    context 'with deleted before created at' do
      let(:role_params) do
        role_defaults.merge(deleted_at: Date.new(2014, 3, 4),
                            created_at: Date.new(2014, 3, 5))
      end

      it 'does not create role' do
        expect { post :create, group_id: group.id, role: role_params }.not_to change { Role.with_deleted.count }
        role.should have(1).error_on(:deleted_at)
      end
    end

    context 'with deleted before created at and empty type' do
      let(:role_params) do
        role_defaults.merge(deleted_at: Date.new(2014, 3, 4),
                            created_at: Date.new(2014, 3, 5),
                            type: '')
      end

      it 'does not create role' do
        expect { post :create, group_id: group.id, role: role_params }.not_to change { Role.with_deleted.count }
        role.should have(1).error_on(:type)
        role.should have(1).error_on(:deleted_at)
        should render_template('crud/new')
      end
    end

  end

end
