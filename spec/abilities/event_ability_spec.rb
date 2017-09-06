# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe EventAbility do

  subject { Ability.new(role.person.reload) }

  context 'event creation/update' do

    allowed_roles = [
      # kantonalverband
      [:be, 'Kantonsleitung'],
      [:be, 'VerantwortungAusbildung'],
      [:be, 'Sekretariat'],
      # region
      [:bern, 'Regionalleitung'],
      [:bern, 'VerantwortungAusbildung'],
      [:bern, 'Sekretariat'],
      # bund
      [:bund, 'MitarbeiterGs'],
      [:bund, 'Sekretariat'],
      [:bund, 'AssistenzAusbildung']
    ]

    allowed_roles.each do |r|
      context "#{r.second} in group #{r.first.to_s}" do
        let(:group) { groups(r.first) }
        let(:role) { Fabricate(group.class.name + '::' + r.second, group: group) }

        it "is allowed to create/update event" do
          event = Fabricate(:event, groups: [group])
          is_expected.to be_able_to(:create, event)
          is_expected.to be_able_to(:update, event)
        end

        it "is allowed to create/update course" do
          event = Fabricate(:pbs_course, groups: [group])
          is_expected.to be_able_to(:create, event)
          is_expected.to be_able_to(:update, event)
          is_expected.to be_able_to(:show_camp_application, event)
        end

        it "is allowed to create/update camp" do
          event = Fabricate(:pbs_camp, groups: [group])
          is_expected.to be_able_to(:create, event)
          is_expected.to be_able_to(:update, event)
          is_expected.to be_able_to(:index_revoked_participations, event)
          is_expected.to be_able_to(:show_camp_application, event)
          is_expected.not_to be_able_to(:create_camp_application, event)
        end
      end
    end

    context 'in abteilung' do
      let(:group) { groups(:patria) }

      context 'abteilungsleitung' do
        let(:role) { Fabricate(Group::Abteilung::Abteilungsleitung.name, group: group) }

        it "is allowed to create/update event" do
          event = Fabricate(:event, groups: [group])
          is_expected.to be_able_to(:create, event)
          is_expected.to be_able_to(:update, event)
        end

        it "is not allowed to create/update course" do
          event = Fabricate(:pbs_course, groups: [group])
          is_expected.not_to be_able_to(:create, event)
          is_expected.not_to be_able_to(:update, event)
          is_expected.not_to be_able_to(:destroy, event)
          is_expected.not_to be_able_to(:index_participations, event)
          is_expected.not_to be_able_to(:application_market, event)
          is_expected.not_to be_able_to(:qualify, event)
        end

        it "is allowed to create/update camp" do
          event = Fabricate(:pbs_camp, groups: [group])
          is_expected.to be_able_to(:create, event)
          is_expected.to be_able_to(:update, event)
          is_expected.to be_able_to(:index_participations, event)
          is_expected.to be_able_to(:index_revoked_participations, event)
          is_expected.to be_able_to(:show_camp_application, event)
          is_expected.not_to be_able_to(:create_camp_application, event)
        end

        it 'with regionalleitung role is allowed to create/update course' do
          Fabricate(Group::Region::Regionalleitung.name, group: groups(:bern), person: role.person)

          event = Fabricate(:pbs_course, groups: [group])
          is_expected.to be_able_to(:create, event)
          is_expected.to be_able_to(:update, event)
        end

        it 'with regionalleitung role in other region is not allowed to create/update course' do
          Fabricate(Group::Region::Regionalleitung.name, group: groups(:oberland), person: role.person)

          event = Fabricate(:pbs_course, groups: [group])
          is_expected.not_to be_able_to(:create, event)
          is_expected.not_to be_able_to(:update, event)
        end

        it 'with regionalleitung role in other region is allowed to create/update course in other region' do
          Fabricate(Group::Region::Regionalleitung.name, group: groups(:oberland), person: role.person)

          event = Fabricate(:pbs_course, groups: [groups(:berchtold)])
          is_expected.to be_able_to(:create, event)
          is_expected.to be_able_to(:update, event)
        end
      end

      context 'as regionalleitung' do
        let(:role) { Fabricate(Group::Region::Regionalleitung.name, group: groups(:bern)) }

        it "is allowed to update event" do
          event = Fabricate(:event, groups: [group])
          is_expected.not_to be_able_to(:create, event)
          is_expected.to be_able_to(:update, event)
        end

        it "is allowed to create/update course" do
          event = Fabricate(:pbs_course, groups: [group])
          is_expected.to be_able_to(:create, event)
          is_expected.to be_able_to(:update, event)
          is_expected.to be_able_to(:destroy, event)
          is_expected.to be_able_to(:index_participations, event)
          is_expected.to be_able_to(:application_market, event)
          is_expected.to be_able_to(:qualify, event)
        end
      end

      context 'as kantonsleitung' do
        let(:role) { Fabricate(Group::Kantonalverband::Kantonsleitung.name, group: groups(:be)) }

        it "is allowed to update event" do
          event = Fabricate(:event, groups: [group])
          is_expected.not_to be_able_to(:create, event)
          is_expected.to be_able_to(:update, event)
        end

        it "is allowed to create/update course" do
          event = Fabricate(:pbs_course, groups: [group])
          is_expected.to be_able_to(:create, event)
          is_expected.to be_able_to(:update, event)
        end

        it 'is not allowed to create course in region' do
          event = Fabricate(:pbs_course, groups: [groups(:bern)])
          is_expected.not_to be_able_to(:create, event)
          is_expected.to be_able_to(:update, event)
        end
      end

      context 'as bundesleitung' do
        let(:role) { Fabricate(Group::Bund::MitarbeiterGs.name, group: groups(:bund)) }

        it "is allowed to update event" do
          event = Fabricate(:event, groups: [group])
          is_expected.not_to be_able_to(:create, event)
          is_expected.to be_able_to(:update, event)
        end

        it "is allowed to update course" do
          event = Fabricate(:pbs_course, groups: [group])
          is_expected.not_to be_able_to(:create, event)
          is_expected.to be_able_to(:update, event)
        end
      end

      context 'as course\'s advisor' do

        it "is allowed to update course" do
          event = Fabricate(:pbs_course, groups: [group])
          child = people(:child)
          event.update!(advisor_id: child.id)
          ability = Ability.new(child)

          expect(ability).not_to be_able_to(:create, event)
          expect(ability).to be_able_to(:update, event)
        end
      end

    end
  end

  context 'camp application' do

    let(:group) { groups(:schekka) }
    let(:role) { Fabricate(Group::Region::VerantwortungProgramm.name, group: groups(:bern)) }

    context 'show' do
      it 'is possible for leader' do
        event = Fabricate(:pbs_camp, groups: [group])
        Fabricate(Event::Camp::Role::Leader.name,
                  participation: Fabricate(:event_participation, event: event, person: role.person))
        is_expected.to be_able_to(:update, event)
        is_expected.to be_able_to(:show_camp_application, event)
      end

      it 'is not possible for anyone' do
        event = Fabricate(:pbs_camp, groups: [group])
        Fabricate(Event::Camp::Role::Helper.name,
                  participation: Fabricate(:event_participation, event: event, person: role.person))
        is_expected.not_to be_able_to(:update, event)
        is_expected.not_to be_able_to(:show_camp_application, event)
      end
    end

    context 'create' do
      it 'is possible for coach' do
        event = Fabricate(:pbs_camp, groups: [group], coach_id: role.person_id)
        is_expected.to be_able_to(:update, event)
        is_expected.to be_able_to(:show_camp_application, event)
        is_expected.to be_able_to(:create_camp_application, event)
      end

      it 'is not possible for leaders' do
        event = Fabricate(:pbs_camp, groups: [group])
        Fabricate(Event::Camp::Role::Helper.name,
                  participation: Fabricate(:event_participation, event: event, person: role.person))
        is_expected.not_to be_able_to(:create_camp_application, event)
      end

      context 'al' do
        let(:role) { roles(:al_schekka) }

        it 'is not possible for al' do
          event = Fabricate(:pbs_camp, groups: [group], abteilungsleitung_id: role.person_id)
          is_expected.to be_able_to(:update, event)
          is_expected.to be_able_to(:show_camp_application, event)
          is_expected.not_to be_able_to(:create_camp_application, event)
        end
      end
    end
  end


  context :modify_superior do

    context 'mitarbeiter gs' do
      let(:role) { Fabricate(Group::Bund::MitarbeiterGs.name.to_sym, group: groups(:bund)) }

      context 'in bund' do
        it 'may modify superior attributes' do
          is_expected.to be_able_to(:modify_superior, events(:bund_course))
        end
      end

      context 'in kanton' do
        it 'may modify superior attributes' do
          is_expected.to be_able_to(:modify_superior, events(:top_course))
        end
      end
    end

    context 'mitarbeiter gs' do
      let(:role) { Fabricate(Group::Bund::AssistenzAusbildung.name.to_sym, group: groups(:bund)) }

      context 'in bund' do
        it 'may modify superior attributes' do
          is_expected.to be_able_to(:modify_superior, events(:bund_course))
        end
      end

      context 'in kanton' do
        it 'may modify superior attributes' do
          is_expected.to be_able_to(:modify_superior, events(:top_course))
        end
      end
    end

    context 'sekretariat' do
      let(:role) { Fabricate(Group::Bund::Sekretariat.name.to_sym, group: groups(:bund)) }

      context 'in bund' do
        it 'may modify superior attributes' do
          is_expected.not_to be_able_to(:modify_superior, events(:bund_course))
        end
      end

      context 'in kanton' do
        it 'may modify superior attributes' do
          is_expected.not_to be_able_to(:modify_superior, events(:top_course))
        end
      end
    end
  end

  context :list_all do
    context Group::Kantonalverband::Sekretariat do
      let(:role) { Fabricate(Group::Kantonalverband::Sekretariat.name.to_sym, group: groups(:be)) }

      it 'may list all courses' do
        is_expected.to be_able_to(:list_all, Event::Course)
      end
    end

    context Group::Ausbildungskommission::Mitglied  do
      let(:role) do
        Fabricate(Group::Ausbildungskommission::Mitglied.name.to_sym,
                  group: Fabricate(Group::Ausbildungskommission.name.to_sym, parent: groups(:bund)))
      end

      it 'may list all courses' do
        is_expected.to be_able_to(:list_all, Event::Course)
      end
    end

    context Group::BundesGremium::Leitung  do
      let(:role) do
        Fabricate(Group::BundesGremium::Leitung.name.to_sym,
                  group: Fabricate(Group::BundesGremium.name.to_sym, parent: groups(:bund)))
      end

      it 'may not list all courses' do
        is_expected.not_to be_able_to(:list_all, Event::Course)
      end
    end
  end

end
