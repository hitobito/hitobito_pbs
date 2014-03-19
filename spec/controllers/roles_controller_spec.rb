require 'spec_helper'
describe RolesController do


  let(:group)  { groups(:bund) }
  let(:person) { people(:al_schekka) }
  let(:role)   { assigns(:role).model }

  let(:role_defaults) do  { group_id: group.id,
                            person_id: person.id,
                            type: Group::Bund::MitarbeiterGs.sti_name } end

  before { sign_in(people(:bulei)) }

  describe 'POST #create' do

    context 'with valid params' do
      let(:role_params) do role_defaults.merge(created_at: Date.new(2014, 3, 4),
                                               deleted_at: Date.new(2014, 3, 5)) end

      it 'creates role with dates set' do
        expect { post :create, group_id: group.id, role: role_params }.to change { Role.with_deleted.count }.by(1)

        role.created_at.to_date.should eq Date.new(2014, 3, 4)
        role.deleted_at.to_date.should eq Date.new(2014, 3, 5)
      end
    end

    context 'with deleted before created at' do
      let(:role_params) do role_defaults.merge(deleted_at: Date.new(2014, 3, 4),
                                               created_at: Date.new(2014, 3, 5)) end

      it 'does not create role' do
        expect { post :create, group_id: group.id, role: role_params }.not_to change { Role.with_deleted.count }
        role.should have(1).error_on(:deleted_at)
      end
    end

  end


  describe 'POST #update' do

    context 'with deleted before created at and empty type' do

      let(:role_params) do role_defaults.merge(deleted_at: Date.new(2014, 3, 4),
                                               created_at: Date.new(2014, 3, 5),
                                               type: '') end

      it 'does not create role' do
        expect { post :create, group_id: group.id, role: role_params }.not_to change { Role.with_deleted.count }
        role.should have(1).error_on(:type)
        role.should have(1).error_on(:deleted_at)
      end
    end
  end

end
