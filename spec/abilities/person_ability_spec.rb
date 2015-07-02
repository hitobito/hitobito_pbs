# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe PersonAbility do

  subject { ability }
  let(:ability) { Ability.new(role.person.reload) }


  describe :layer_and_below_full do
    let(:role) { Fabricate(Group::FederalBoard::Member.name.to_sym, group: groups(:federal_board)) }

    it 'may modify any public role in lower layers' do
      other = Fabricate(Group::Flock::CampLeader.name.to_sym, group: groups(:bern))
      is_expected.to be_able_to(:update, other.person.reload)
      is_expected.to be_able_to(:update, other)
    end

    it 'may modify its role' do
      is_expected.to be_able_to(:update, role)
    end

    it 'may not destroy its role' do
      is_expected.not_to be_able_to(:destroy, role)
    end

    it 'may modify externals in the same layer' do
      other = Fabricate(Group::Federation::External.name.to_sym, group: groups(:ch))
      is_expected.to be_able_to(:update, other.person.reload)
      is_expected.to be_able_to(:update, other)
    end

    it 'may not view any children in lower layers' do
      other = Fabricate(Group::ChildGroup::Child.name.to_sym, group: groups(:asterix))
      is_expected.not_to be_able_to(:show_full, other.person.reload)
      is_expected.not_to be_able_to(:update, other)
    end

    it 'may not view any externals in lower layers' do
      other = Fabricate(Group::State::External.name.to_sym, group: groups(:be))
      is_expected.not_to be_able_to(:show_full, other.person.reload)
      is_expected.not_to be_able_to(:update, other)
    end

    it 'may view alumni in lower layers' do
      other = Fabricate(Group::State::Alumnus.name.to_sym, group: groups(:be))
      is_expected.to be_able_to(:show_full, other.person.reload)
      is_expected.to be_able_to(:update, other)
    end


    it 'may not modify any restricted roles in lower layers' do
      other = Fabricate(Group::Flock::Coach.name.to_sym, group: groups(:bern))
      Fabricate(Group::State::Coach.name.to_sym, group: groups(:be), person: other.person)
      is_expected.not_to be_able_to(:update, other)
      is_expected.not_to be_able_to(:destroy, other)
      is_expected.not_to be_able_to(:create, other)
    end

    it 'may index groups in lower layer' do
      is_expected.to be_able_to(:index_people, groups(:bern))
      is_expected.to be_able_to(:index_full_people, groups(:bern))
      is_expected.not_to be_able_to(:index_local_people, groups(:bern))
    end

    it 'may index groups in same layer' do
      is_expected.to be_able_to(:index_people, groups(:ch))
      is_expected.to be_able_to(:index_full_people, groups(:ch))
      is_expected.to be_able_to(:index_local_people, groups(:ch))
    end
  end


  describe 'layer_and_below_full in flock' do
    let(:role) { Fabricate(Group::Flock::Leader.name.to_sym, group: groups(:bern)) }

    it 'may create other users' do
      is_expected.to be_able_to(:create, Person)
    end

    it 'may modify its role' do
      is_expected.to be_able_to(:update, role)
    end

    it 'may not destroy its role' do
      is_expected.not_to be_able_to(:destroy, role)
    end

    it 'may modify any public role in same layer' do
      other = Fabricate(Group::Flock::CampLeader.name.to_sym, group: groups(:bern))
      is_expected.to be_able_to(:update, other.person.reload)
      is_expected.to be_able_to(:update, other)
      is_expected.to be_able_to(:create, other)
      is_expected.to be_able_to(:destroy, other)
    end

    it 'may not view any public role in upper layers' do
      other = Fabricate(Group::StateBoard::Leader.name.to_sym, group: groups(:be_board))
      is_expected.not_to be_able_to(:show_full, other.person.reload)
      is_expected.not_to be_able_to(:update, other)
    end

    it 'may not view any public role in other flocks' do
      other = Fabricate(Group::Flock::Leader.name.to_sym, group: groups(:thun))
      is_expected.not_to be_able_to(:show_full, other.person.reload)
      is_expected.not_to be_able_to(:update, other)
    end

    it 'may modify externals in his flock' do
      other = Fabricate(Group::Flock::External.name.to_sym, group: groups(:bern))
      is_expected.to be_able_to(:update, other.person.reload)
      is_expected.to be_able_to(:update, other)
      is_expected.to be_able_to(:create, other)
      is_expected.to be_able_to(:destroy, other)
    end

    it 'may not modify restricted in his flock' do
      other = Fabricate(Group::Flock::Coach.name.to_sym, group: groups(:bern))
      is_expected.not_to be_able_to(:update, other.person.reload)
      is_expected.not_to be_able_to(:update, other)
      is_expected.not_to be_able_to(:create, other)
      is_expected.not_to be_able_to(:destroy, other)
    end

    it 'may modify children in his flock' do
      other = Fabricate(Group::ChildGroup::Child.name.to_sym, group: groups(:asterix))
      is_expected.to be_able_to(:update, other.person.reload)
      is_expected.to be_able_to(:update, other)
      is_expected.to be_able_to(:create, other)
      is_expected.to be_able_to(:destroy, other)
    end

    it 'may not view any externals in upper layers' do
      other = Fabricate(Group::State::External.name.to_sym, group: groups(:be))
      is_expected.not_to be_able_to(:show_full, other.person.reload)
      is_expected.not_to be_able_to(:update, other)
    end

    it 'may index groups in upper layer' do
      is_expected.to be_able_to(:index_people, groups(:ch))
      is_expected.not_to be_able_to(:index_full_people, groups(:ch))
      is_expected.not_to be_able_to(:index_local_people, groups(:ch))
    end

    it 'may index groups in same layer' do
      is_expected.to be_able_to(:index_people, groups(:bern))
      is_expected.to be_able_to(:index_full_people, groups(:bern))
      is_expected.to be_able_to(:index_local_people, groups(:bern))
    end
  end


  describe :layer_and_below_read do
    # member with additional group_admin role
    let(:group_role) { Fabricate(Group::StateBoard::GroupAdmin.name.to_sym, group: groups(:be_board)) }
    let(:role)       { Fabricate(Group::StateBoard::Supervisor.name.to_sym, group: groups(:be_board), person: group_role.person) }

    it 'may view details of himself' do
      is_expected.to be_able_to(:show_full, role.person.reload)
    end

    it 'may modify himself' do
      is_expected.to be_able_to(:update, role.person.reload)
    end

    it 'may modify its read role' do
      is_expected.to be_able_to(:update, role)
    end

    it 'may destroy its read role' do
      is_expected.to be_able_to(:destroy, role)
    end

    it 'may modify its group_full role' do
      is_expected.to be_able_to(:update, group_role)
    end

    it 'may not destroy its group_full role' do
      is_expected.not_to be_able_to(:destroy, group_role)
    end

    it 'may create other users as group admin' do
      is_expected.to be_able_to(:create, Person)
    end

    it 'may view any public role in same layer' do
      other = Fabricate(Group::StateProfessionalGroup::Member.name.to_sym, group: groups(:be_security))
      is_expected.to be_able_to(:show_full, other.person.reload)
    end

    it 'may not modify any role in same layer' do
      other = Fabricate(Group::StateProfessionalGroup::Member.name.to_sym, group: groups(:be_security))
      is_expected.not_to be_able_to(:update, other.person.reload)
      is_expected.not_to be_able_to(:update, other)
    end

    it 'may view any externals in same layer' do
      other = Fabricate(Group::StateProfessionalGroup::External.name.to_sym, group: groups(:be_security))
      is_expected.to be_able_to(:show_full, other.person.reload)
    end

    it 'may modify any role in same group' do
      other = Fabricate(Group::StateBoard::Member.name.to_sym, group: groups(:be_board))
      is_expected.to be_able_to(:update, other.person.reload)
      is_expected.to be_able_to(:update, other)
    end

    it 'may not view details of any public role in upper layers' do
      other = Fabricate(Group::FederalBoard::Member.name.to_sym, group: groups(:federal_board))
      is_expected.not_to be_able_to(:show_full, other.person.reload)
    end

    it 'may view any public role in groups below' do
      other = Fabricate(Group::Flock::Leader.name.to_sym, group: groups(:thun))
      is_expected.to be_able_to(:show_full, other.person.reload)
    end

    it 'may not modify any public role in groups below' do
      other = Fabricate(Group::Flock::Leader.name.to_sym, group: groups(:thun))
      is_expected.not_to be_able_to(:update, other.person.reload)
      is_expected.not_to be_able_to(:update, other)
    end

    it 'may not view any externals in groups below' do
      other = Fabricate(Group::Flock::External.name.to_sym, group: groups(:thun))
      is_expected.not_to be_able_to(:show, other.person.reload)
    end

    it 'may view alumni in groups below' do
      other = Fabricate(Group::Flock::Alumnus.name.to_sym, group: groups(:thun))
      is_expected.to be_able_to(:show, other.person.reload)
    end

    it 'may index groups in lower layer' do
      is_expected.to be_able_to(:index_people, groups(:bern))
      is_expected.to be_able_to(:index_full_people, groups(:bern))
      is_expected.not_to be_able_to(:index_local_people, groups(:bern))
    end

    it 'may index groups in same layer' do
      is_expected.to be_able_to(:index_people, groups(:be))
      is_expected.to be_able_to(:index_full_people, groups(:be))
      is_expected.to be_able_to(:index_local_people, groups(:be))
    end
  end

  describe :contact_data do
    let(:role) { Fabricate(Group::StateBoard::Member.name.to_sym, group: groups(:be_board)) }

    it 'may view details of himself' do
      is_expected.to be_able_to(:show_full, role.person.reload)
    end

    it 'may modify himself' do
      is_expected.to be_able_to(:update, role.person.reload)
    end

    it 'may not modify his role' do
      is_expected.not_to be_able_to(:update, role)
    end

    it 'may not create other users' do
      is_expected.not_to be_able_to(:create, Person)
    end

    it 'may view others in same group' do
      other = Fabricate(Group::StateBoard::Leader.name.to_sym, group: groups(:be_board))
      is_expected.to be_able_to(:show, other.person.reload)
    end

    it 'may view details of others in same group' do
      other = Fabricate(Group::StateBoard::Member.name.to_sym, group: groups(:be_board))
      is_expected.to be_able_to(:show_details, other.person.reload)
    end
    it 'may not view full of others in same group' do
      other = Fabricate(Group::StateBoard::Member.name.to_sym, group: groups(:be_board))
      is_expected.not_to be_able_to(:show_full, other.person.reload)
    end

    it 'may not modify others in same group' do
      other = Fabricate(Group::StateBoard::Member.name.to_sym, group: groups(:be_board))
      is_expected.not_to be_able_to(:update, other.person.reload)
      is_expected.not_to be_able_to(:update, other)
    end

    it 'may show any public role in same layer' do
      other = Fabricate(Group::StateProfessionalGroup::Member.name.to_sym, group: groups(:be_security))
      is_expected.to be_able_to(:show, other.person.reload)
    end

    it 'may not view details of public role in same layer' do
      other = Fabricate(Group::StateProfessionalGroup::Member.name.to_sym, group: groups(:be_security))
      is_expected.not_to be_able_to(:show_full, other.person.reload)
    end

    it 'may not modify any role in same layer' do
      other = Fabricate(Group::StateProfessionalGroup::Member.name.to_sym, group: groups(:be_security))
      is_expected.not_to be_able_to(:update, other.person.reload)
      is_expected.not_to be_able_to(:update, other)
    end

    it 'may not view externals in other group of same layer' do
      other = Fabricate(Group::StateProfessionalGroup::External.name.to_sym, group: groups(:be_security))
      is_expected.not_to be_able_to(:show, other.person.reload)
    end

    it 'may view any public role in upper layers' do
      other = Fabricate(Group::FederalBoard::Member.name.to_sym, group: groups(:federal_board))
      is_expected.to be_able_to(:show, other.person.reload)
    end

    it 'may not view details of any public role in upper layers' do
      other = Fabricate(Group::FederalBoard::Member.name.to_sym, group: groups(:federal_board))
      is_expected.not_to be_able_to(:show_full, other.person.reload)
    end

    it 'may view any public role in groups below' do
      other = Fabricate(Group::Flock::Leader.name.to_sym, group: groups(:thun))
      is_expected.to be_able_to(:show, other.person.reload)
    end

    it 'may not modify any public role in groups below' do
      other = Fabricate(Group::Flock::Leader.name.to_sym, group: groups(:thun))
      is_expected.not_to be_able_to(:update, other.person.reload)
      is_expected.not_to be_able_to(:update, other)
    end

    it 'may not view any externals in groups below' do
      other = Fabricate(Group::Flock::External.name.to_sym, group: groups(:thun))
      is_expected.not_to be_able_to(:show, other.person.reload)
    end

    it 'may index own group' do
      is_expected.to be_able_to(:index_people, groups(:be_board))
      is_expected.to be_able_to(:index_local_people, groups(:be_board))
      is_expected.not_to be_able_to(:index_full_people, groups(:be_board))
    end

    it 'may index groups anywhere' do
      is_expected.to be_able_to(:index_people, groups(:no_board))
      is_expected.not_to be_able_to(:index_full_people, groups(:no_board))
      is_expected.not_to be_able_to(:index_local_people, groups(:no_board))
    end

  end

  describe :group_read do
    let(:role) { Fabricate(Group::StateWorkGroup::Member.name.to_sym, group: groups(:be_state_camp)) }

    it 'may view details of himself' do
      is_expected.to be_able_to(:show_full, role.person.reload)
    end

    it 'may update himself' do
      is_expected.to be_able_to(:update, role.person.reload)
    end

    it 'may not update his role' do
      is_expected.not_to be_able_to(:update, role)
    end

    it 'may not create other users' do
      is_expected.not_to be_able_to(:create, Person)
    end

    it 'may view others in same group' do
      other = Fabricate(Group::StateWorkGroup::Leader.name.to_sym, group: groups(:be_state_camp))
      is_expected.to be_able_to(:show, other.person.reload)
    end

    it 'may view externals in same group' do
      other = Fabricate(Group::StateWorkGroup::External.name.to_sym, group: groups(:be_state_camp))
      is_expected.to be_able_to(:show, other.person.reload)
    end

    it 'may view alumni in same group' do
      other = Fabricate(Group::StateWorkGroup::Alumnus.name.to_sym, group: groups(:be_state_camp))
      is_expected.to be_able_to(:show, other.person.reload)
    end

    it 'may not view details of others in same group' do
      other = Fabricate(Group::StateWorkGroup::Leader.name.to_sym, group: groups(:be_state_camp))
      is_expected.to be_able_to(:show_details, other.person.reload)
    end

    it 'may not view full of others in same group' do
      other = Fabricate(Group::StateWorkGroup::Leader.name.to_sym, group: groups(:be_state_camp))
      is_expected.not_to be_able_to(:show_full, other.person.reload)
    end

    it 'may not view public role in same layer' do
      other = Fabricate(Group::StateProfessionalGroup::Member.name.to_sym, group: groups(:be_security))
      is_expected.not_to be_able_to(:show, other.person.reload)
    end

    it 'may index same group' do
      is_expected.to be_able_to(:index_people, groups(:be_state_camp))
      is_expected.to be_able_to(:index_local_people, groups(:be_state_camp))
      is_expected.not_to be_able_to(:index_full_people, groups(:be_state_camp))
    end

    it 'may not index groups in same layer' do
      is_expected.not_to be_able_to(:index_people, groups(:be_board))
      is_expected.not_to be_able_to(:index_full_people, groups(:be_board))
      is_expected.not_to be_able_to(:index_local_people, groups(:be_board))
    end
  end

  describe 'no permissions' do
    let(:role) { Fabricate(Group::StateWorkGroup::External.name.to_sym, group: groups(:be_state_camp)) }

    it 'may view details of himself' do
      is_expected.to be_able_to(:show_full, role.person.reload)
    end

    it 'may modify himself' do
      is_expected.to be_able_to(:update, role.person.reload)
    end

    it 'may not modify his role' do
      is_expected.not_to be_able_to(:update, role)
    end

    it 'may not create other users' do
      is_expected.not_to be_able_to(:create, Person)
    end

    it 'may not view others in same group' do
      other = Fabricate(Group::StateWorkGroup::Leader.name.to_sym, group: groups(:be_state_camp))
      is_expected.not_to be_able_to(:show, other.person.reload)
    end

    it 'may not view externals in same group' do
      other = Fabricate(Group::StateWorkGroup::External.name.to_sym, group: groups(:be_state_camp))
      is_expected.not_to be_able_to(:show, other.person.reload)
    end

    it 'may not view alumni in same group' do
      other = Fabricate(Group::StateWorkGroup::Alumnus.name.to_sym, group: groups(:be_state_camp))
      is_expected.not_to be_able_to(:show, other.person.reload)
    end

    it 'may not view details of others in same group' do
      other = Fabricate(Group::StateWorkGroup::Leader.name.to_sym, group: groups(:be_state_camp))
      is_expected.not_to be_able_to(:show_details, other.person.reload)
    end

    it 'may not view full of others in same group' do
      other = Fabricate(Group::StateWorkGroup::Leader.name.to_sym, group: groups(:be_state_camp))
      is_expected.not_to be_able_to(:show_full, other.person.reload)
    end

    it 'may not view public role in same layer' do
      other = Fabricate(Group::StateProfessionalGroup::Member.name.to_sym, group: groups(:be_security))
      is_expected.not_to be_able_to(:show, other.person.reload)
    end

    it 'may index same group' do
      is_expected.not_to be_able_to(:index_people, groups(:be_state_camp))
      is_expected.not_to be_able_to(:index_local_people, groups(:be_state_camp))
      is_expected.not_to be_able_to(:index_full_people, groups(:be_state_camp))
    end

    it 'may not index groups in same layer' do
      is_expected.not_to be_able_to(:index_people, groups(:be_board))
      is_expected.not_to be_able_to(:index_full_people, groups(:be_board))
      is_expected.not_to be_able_to(:index_local_people, groups(:be_board))
    end
  end

  describe 'people filter' do

    context 'root layer and below full' do
      let(:role) { Fabricate(Group::FederalBoard::Member.name.to_sym, group: groups(:federal_board)) }

      context 'in group from same layer' do
        let(:group) { groups(:federal_board) }

        it 'may create people filters' do
          is_expected.to be_able_to(:create, group.people_filters.new)
        end
      end

      context 'in group from lower layer' do
        let(:group) { groups(:bern) }

        it 'may not create people filters' do
          is_expected.not_to be_able_to(:create, group.people_filters.new)
        end

        it 'may define new people filters' do
          is_expected.to be_able_to(:new, group.people_filters.new)
        end
      end
    end

    context 'bottom layer and below full' do
      let(:role) { Fabricate(Group::Flock::Leader.name.to_sym, group: groups(:bern)) }

      context 'in group from same layer' do
        let(:group) { groups(:bern) }

        it 'may create people filters' do
          is_expected.to be_able_to(:create, group.people_filters.new)
        end
      end

      context 'in group from upper layer' do
        let(:group) { groups(:be) }

        it 'may not create people filters' do
          is_expected.not_to be_able_to(:create, group.people_filters.new)
        end

        it 'may define new people filters' do
          is_expected.to be_able_to(:new, group.people_filters.new)
        end
      end
    end

    context 'layer and below read' do
      let(:role) { Fabricate(Group::StateBoard::Supervisor.name.to_sym, group: groups(:be_board)) }

      context 'in group from same layer' do
        let(:group) { groups(:be_board) }

        it 'may not create people filters' do
          is_expected.not_to be_able_to(:create, group.people_filters.new)
        end

        it 'may define new people filters' do
          is_expected.to be_able_to(:new, group.people_filters.new)
        end
      end

      context 'in group from lower layer' do
        let(:group) { groups(:bern) }

        it 'may not create people filters' do
          is_expected.not_to be_able_to(:create, group.people_filters.new)
        end

        it 'may define new people filters' do
          is_expected.to be_able_to(:new, group.people_filters.new)
        end
      end
    end
  end

  describe :show_details do
    let(:other) { Fabricate(Group::StateBoard::Member.name.to_sym, group: groups(:be_board)).person.reload }

    context 'layer and below full' do
      let(:role) { Fabricate(Group::StateBoard::Leader.name.to_sym, group: groups(:be_board)) }
      it 'can show_details' do
        is_expected.to be_able_to(:show_details, other)
        is_expected.to be_able_to(:show_full, other)
      end
    end

    context 'same group' do
      let(:role) { Fabricate(Group::StateBoard::Member.name.to_sym, group: groups(:be_board)) }
      it 'can show_details' do
        is_expected.to be_able_to(:show_details, other)
        is_expected.not_to be_able_to(:show_full, other)
      end
    end

    context 'group below' do
      let(:role) { Fabricate(Group::RegionalBoard::Member.name.to_sym, group: groups(:city_board)) }
      it 'cannot show_details' do
        is_expected.not_to be_able_to(:show_details, other)
        is_expected.not_to be_able_to(:show_full, other)
      end
    end
  end

  describe :send_password_instructions do
    let(:other) { Fabricate(Group::StateBoard::Member.name.to_sym, group: groups(:be_board)).person.reload }

    context 'layer and below full' do
      let(:role) { Fabricate(Group::StateBoard::Leader.name.to_sym, group: groups(:be_board)) }
      it 'can send_password_instructions' do
        is_expected.to be_able_to(:send_password_instructions, other)
      end

      it 'can send_password_instructions for external role' do
        external = Fabricate(Group::StateBoard::External.name.to_sym, group: groups(:be_board)).person.reload
        is_expected.to be_able_to(:send_password_instructions, external)
      end

      it 'cannot send_password_instructions for self' do
        is_expected.not_to be_able_to(:send_password_instructions, role.person.reload)
      end
    end

    context 'same group' do
      let(:role) { Fabricate(Group::StateBoard::Member.name.to_sym, group: groups(:be_board)) }
      it 'cannot send_password_instructions' do
        is_expected.not_to be_able_to(:send_password_instructions, other)
      end
    end

    context 'group below' do
      let(:role) { Fabricate(Group::RegionalBoard::Member.name.to_sym, group: groups(:city_board)) }
      it 'cannot send_password_instructions' do
        is_expected.not_to be_able_to(:send_password_instructions, other)
      end
    end
  end

  describe :update_participant do
    let(:course)      { events(:top_course) }
    let(:role)        { Fabricate(Group::StateAgency::Leader.name, group: groups(:no_agency)) }
    let(:participant) { people(:flock_leader_bern) }

    before { course.update_attributes!(application_contact_id: groups(:be_agency).id) }

    Event::Course.possible_states.each do |state|
      it "cannot update participant when event is in state #{state}" do
        course.update_attributes!(state: state)
        is_expected.not_to be_able_to(:update, participant)
      end
    end

    context 'event hosts by "no"' do
      Jubla::PersonAbility::STATES.each do |state|
        it "can update participant when event is in state #{state}" do
          course.groups << groups(:no)
          course.update_attributes!(state: state)
          is_expected.to be_able_to(:update, participant)
        end
      end
    end
  end

end
