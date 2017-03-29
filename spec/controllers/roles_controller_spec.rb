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
        is_expected.to render_template('edit')
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

        expect(role.created_at.to_date).to eq Date.new(2014, 3, 4)
        expect(role.deleted_at.to_date).to eq Date.new(2014, 3, 5)
        is_expected.to redirect_to(group_people_path(group.id))
      end

      it 'redirects' do
        expect { post :create, group_id: group.id, role: role_params }.to change { Role.with_deleted.count }.by(1)
        expect(flash[:notice]).to eq 'Rolle <i>Mitarbeiter GS</i> für <i>AL Schekka / Torben</i> in <i>Pfadibewegung Schweiz</i> wurde erfolgreich erstellt.'
        is_expected.to redirect_to(group_people_path(group.id))
      end
    end

    context 'with deleted before created at' do
      let(:role_params) do
        role_defaults.merge(deleted_at: Date.new(2014, 3, 4),
                            created_at: Date.new(2014, 3, 5))
      end

      it 'does not create role' do
        expect { post :create, group_id: group.id, role: role_params }.not_to change { Role.with_deleted.count }
        expect(role).to have(1).error_on(:deleted_at)
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
        expect(role).to have(1).error_on(:type)
        expect(role).to have(1).error_on(:deleted_at)
        is_expected.to render_template('crud/new')
      end
    end

    context 'notification when gaining access to more person data' do
      let(:actuator)      { people(:al_schekka) }
      let(:home_group)    { groups(:schekka) }
      let(:foreign_group) { groups(:chaeib) }
      let(:person)        { Fabricate(:person, first_name: 'Asdf') }

      before do
        sign_in(actuator)
        Person.stamper = actuator
      end

      after { Person.reset_stamper }

      it 'is sent on role creation with more access' do
        Fabricate(Group::Abteilung::Sekretariat.name.to_sym, group: foreign_group, person: person)

        role_params = { group_id: home_group.id,
                        person_id: person.id,
                        type: Group::Abteilung::Sekretariat.sti_name }
        expect { post :create, group_id: home_group.id, role: role_params }.
          to change { Delayed::Job.count }.by(1)
        expect(Delayed::Job.first.handler).to include('GroupMembershipJob')
      end

      it 'is not sent on role creation with equal access' do
        Fabricate(Group::Abteilung::Sekretariat.name.to_sym, group: home_group, person: person)

        role_params = { group_id: home_group.id,
                        person_id: person.id,
                        type: Group::Abteilung::Revisor.sti_name }
        expect { post :create, group_id: home_group.id, role: role_params }.
          not_to change { Delayed::Job.count }
      end

      it 'is not sent on role creation for new person' do
        role_params = { group_id: home_group.id,
                        person_id: nil,
                        type: Group::Abteilung::Sekretariat.sti_name,
                        new_person: { first_name: 'Asdf', last_name: 'Asdf' } }
        expect { post :create, group_id: home_group.id, role: role_params }.
          not_to change { Delayed::Job.count }
      end

      it 'is not sent on role update (not possible to gain access via update)' do
        child_group = groups(:sunnewirbu)
        role = Fabricate(Group::Abteilung::Revisor.name.to_sym, group: home_group, person: person)

        role_params = { group_id: child_group.id,
                        type: Group::Woelfe::Wolf.sti_name }
        expect { put :update, group_id: home_group.id, id: role.id, role: role_params }.
          not_to change { Delayed::Job.count }
      end

      it 'is not sent on role destruction' do
        role = Fabricate(Group::Abteilung::Sekretariat.name.to_sym, group: home_group, person: person)

        expect { delete :destroy, group_id: home_group.id, id: role.id }.
          not_to change { Delayed::Job.count }
      end
    end

  end

end
