#  Copyright (c) 2012-2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe EventAbility do
  subject { Ability.new(role.person.reload) }

  context "event creation/update" do
    allowed_roles = [
      # kantonalverband
      [:be, "Kantonsleitung"],
      [:be, "VerantwortungAusbildung"],
      [:be, "Sekretariat"],
      # region
      [:bern, "Regionalleitung"],
      [:bern, "VerantwortungAusbildung"],
      [:bern, "Sekretariat"],
      # bund
      [:bund, "MitarbeiterGs"],
      [:bund, "Sekretariat"],
      [:bund, "AssistenzAusbildung"]
    ]

    allowed_roles.each do |r|
      context "#{r.second} in group #{r.first}" do
        let(:group) { groups(r.first) }
        let(:role) { Fabricate(group.class.name + "::" + r.second, group: group) }

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

    context "in abteilung" do
      let(:group) { groups(:patria) }

      context "abteilungsleitung" do
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

        it "with regionalleitung role is allowed to create/update course" do
          Fabricate(Group::Region::Regionalleitung.name, group: groups(:bern), person: role.person)

          event = Fabricate(:pbs_course, groups: [group])
          is_expected.to be_able_to(:create, event)
          is_expected.to be_able_to(:update, event)
        end

        it "with regionalleitung role in other region is not allowed to create/update course" do
          Fabricate(Group::Region::Regionalleitung.name, group: groups(:oberland),
            person: role.person)

          event = Fabricate(:pbs_course, groups: [group])
          is_expected.not_to be_able_to(:create, event)
          is_expected.not_to be_able_to(:update, event)
        end

        # rubocop:todo Layout/LineLength
        it "with regionalleitung role in other region is allowed to create/update course in other region" do
          # rubocop:enable Layout/LineLength
          Fabricate(Group::Region::Regionalleitung.name, group: groups(:oberland),
            person: role.person)

          event = Fabricate(:pbs_course, groups: [groups(:berchtold)])
          is_expected.to be_able_to(:create, event)
          is_expected.to be_able_to(:update, event)
        end
      end

      context "as regionalleitung" do
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

      context "as kantonsleitung" do
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

        it "is not allowed to create course in region" do
          event = Fabricate(:pbs_course, groups: [groups(:bern)])
          is_expected.not_to be_able_to(:create, event)
          is_expected.to be_able_to(:update, event)
        end
      end

      context "as bundesleitung" do
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

      context "as course's advisor" do
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

  context "camp application" do
    let(:group) { groups(:schekka) }
    let(:role) { Fabricate(Group::Region::VerantwortungProgramm.name, group: groups(:bern)) }

    context "show" do
      it "is possible for leader" do
        event = Fabricate(:pbs_camp, groups: [group])
        Fabricate(Event::Camp::Role::Leader.name,
          participation: Fabricate(:pbs_participation, event: event, participant: role.person))
        is_expected.to be_able_to(:update, event)
        is_expected.to be_able_to(:show_camp_application, event)
      end

      it "is possible for leader of supercamp" do
        event = Fabricate(:pbs_camp, groups: [group])
        subcamp = Fabricate(:pbs_camp, groups: [group])
        subcamp.move_to_child_of(event)

        Fabricate(Event::Camp::Role::Leader.name,
          participation: Fabricate(:pbs_participation, event: event, participant: role.person))
        is_expected.to be_able_to(:show_details, subcamp)
        is_expected.to be_able_to(:index_participations, subcamp)

        is_expected.not_to be_able_to(:update, subcamp)
        is_expected.not_to be_able_to(:show_camp_application, subcamp)
      end

      it "is not possible for anyone" do
        event = Fabricate(:pbs_camp, groups: [group])
        Fabricate(Event::Camp::Role::Helper.name,
          participation: Fabricate(:pbs_participation, event: event, participant: role.person))
        is_expected.not_to be_able_to(:update, event)
        is_expected.not_to be_able_to(:show_camp_application, event)
      end
    end

    context "create" do
      it "is possible for coach" do
        event = Fabricate(:pbs_camp, groups: [group], coach_id: role.person_id)
        is_expected.to be_able_to(:update, event)
        is_expected.to be_able_to(:show_camp_application, event)
        is_expected.to be_able_to(:create_camp_application, event)
      end

      it "is not possible for leaders" do
        event = Fabricate(:pbs_camp, groups: [group])
        Fabricate(Event::Camp::Role::Helper.name,
          participation: Fabricate(:pbs_participation, event: event, participant: role.person))
        is_expected.not_to be_able_to(:create_camp_application, event)
      end

      context "al" do
        let(:role) { roles(:al_schekka) }

        it "is not possible for al" do
          event = Fabricate(:pbs_camp, groups: [group], abteilungsleitung_id: role.person_id)
          is_expected.to be_able_to(:update, event)
          is_expected.to be_able_to(:show_camp_application, event)
          is_expected.not_to be_able_to(:create_camp_application, event)
        end
      end
    end
  end

  context "camp details" do
    allowed_roles = [[:be, "Kantonsleitung"],
      [:be, "Sekretariat"],
      [:be, "VerantwortungKrisenteam"],
      [:be, "MitgliedKrisenteam"]]

    allowed_roles.each do |r|
      context "#{r.second} in group #{r.first}" do
        let(:group) { groups(r.first) }
        let(:role) { Fabricate(group.class.name + "::" + r.second, group: group) }

        it "is allowed to show_details on camp organized by be" do
          camp = Fabricate(:pbs_camp, groups: [group])
          is_expected.to be_able_to(:show_details, camp)
          is_expected.to be_able_to(:show_crisis_contacts, camp)
        end

        it "is allowed to show_details on camp organized by patria" do
          camp = Fabricate(:pbs_camp, groups: [groups(:patria)])
          is_expected.to be_able_to(:show_details, camp)
          is_expected.to be_able_to(:show_crisis_contacts, camp)
        end

        it "is not allowed to show_details on camp organized by zh" do
          camp = Fabricate(:pbs_camp, groups: [groups(:zh)])
          is_expected.not_to be_able_to(:show_details, camp)
          is_expected.not_to be_able_to(:show_crisis_contacts, camp)
        end

        it "is allowed to show_details on camp organized by zh held in be" do
          KantonalverbandCanton.create!(canton: "be", kantonalverband: group)
          camp = Fabricate(:pbs_camp, groups: [groups(:zh)], canton: "be")
          is_expected.to be_able_to(:show_details, camp)
          is_expected.to be_able_to(:show_crisis_contacts, camp)
        end
      end
    end
  end

  context :manage_attendances do
    context "assistenz ausbildung" do
      let(:role) { Fabricate(Group::Bund::AssistenzAusbildung.name.to_sym, group: groups(:bund)) }

      context "in kanton" do
        it "may manage attendances and qualifications" do
          is_expected.to be_able_to(:manage_attendances, events(:top_course))
          is_expected.to be_able_to(:qualifications_read, events(:top_course))
        end
      end
    end

    context "mitarbeiter gs" do
      let(:role) { Fabricate(Group::Bund::MitarbeiterGs.name.to_sym, group: groups(:bund)) }

      context "in kanton" do
        it "may manage attendances and qualifications" do
          is_expected.not_to be_able_to(:manage_attendances, events(:top_course))
          is_expected.not_to be_able_to(:qualifications_read, events(:top_course))
        end
      end
    end
  end

  context :modify_superior do
    context "mitarbeiter gs" do
      let(:role) { Fabricate(Group::Bund::MitarbeiterGs.name.to_sym, group: groups(:bund)) }

      context "in bund" do
        it "may modify superior attributes" do
          is_expected.to be_able_to(:modify_superior, events(:bund_course))
        end
      end

      context "in kanton" do
        it "may modify superior attributes" do
          is_expected.to be_able_to(:modify_superior, events(:top_course))
        end
      end
    end

    context "mitarbeiter gs" do
      let(:role) { Fabricate(Group::Bund::AssistenzAusbildung.name.to_sym, group: groups(:bund)) }

      context "in bund" do
        it "may modify superior attributes" do
          is_expected.to be_able_to(:modify_superior, events(:bund_course))
        end
      end

      context "in kanton" do
        it "may modify superior attributes" do
          is_expected.to be_able_to(:modify_superior, events(:top_course))
        end
      end
    end

    context "sekretariat" do
      let(:role) { Fabricate(Group::Bund::Sekretariat.name.to_sym, group: groups(:bund)) }

      context "in bund" do
        it "may modify superior attributes" do
          is_expected.not_to be_able_to(:modify_superior, events(:bund_course))
        end
      end

      context "in kanton" do
        it "may modify superior attributes" do
          is_expected.not_to be_able_to(:modify_superior, events(:top_course))
        end
      end
    end
  end

  context :list_all do
    context Group::Kantonalverband::Sekretariat do
      let(:role) { Fabricate(Group::Kantonalverband::Sekretariat.name.to_sym, group: groups(:be)) }

      it "may list all courses" do
        is_expected.to be_able_to(:list_all, Event::Course)
      end
    end

    context Group::Ausbildungskommission::Mitglied do
      let(:role) do
        Fabricate(Group::Ausbildungskommission::Mitglied.name.to_sym,
          group: Fabricate(Group::Ausbildungskommission.name.to_sym, parent: groups(:bund)))
      end

      it "may list all courses" do
        is_expected.to be_able_to(:list_all, Event::Course)
      end
    end

    context Group::BundesGremium::Leitung do
      let(:role) do
        Fabricate(Group::BundesGremium::Leitung.name.to_sym,
          group: Fabricate(Group::BundesGremium.name.to_sym, parent: groups(:bund)))
      end

      it "may not list all courses" do
        is_expected.not_to be_able_to(:list_all, Event::Course)
      end
    end
  end

  context :export_list do
    context "with layer_and_below_full on bund" do
      let(:role) do
        Fabricate(Group::Bund::Adressverwaltung.name.to_sym,
          group: Group.bund)
      end

      it "may export_list" do
        is_expected.to be_able_to(:export_list, Event::Course)
      end
    end

    context "with layer_and_below_full on silverscouts" do
      let(:role) do
        Fabricate(Group::Silverscouts::Verantwortung.name.to_sym,
          group: Group.silverscouts)
      end

      it "may export_list" do
        is_expected.to be_able_to(:export_list, Event::Course)
      end
    end

    context "with layer_and_below_full on root" do
      let(:role) do
        Fabricate(Group::Root::Admin.name.to_sym,
          group: Group.root)
      end

      it "may export_list" do
        is_expected.to be_able_to(:export_list, Event::Course)
      end
    end

    context "with layer_and_below_read on bund" do
      let(:role) do
        Fabricate(Group::Bund::Coach.name.to_sym,
          group: Group.bund)
      end

      it "may not export_list" do
        is_expected.to_not be_able_to(:export_list, Event::Course)
      end
    end

    context "with layer_and_below_full on kantonalverband" do
      let(:role) { Fabricate(Group::Kantonalverband::Sekretariat.name.to_sym, group: groups(:be)) }

      it "may not export_list" do
        is_expected.to_not be_able_to(:export_list, Event::Course)
      end
    end
  end
end
