require 'spec_helper'

describe Event::Camp do

  subject do
    camp = events(:schekka_camp)

    # Prevent automatic abteilungsleitung assignement
    Fabricate(Group::Abteilung::Abteilungsleitung.name, group: camp.groups.first)
    Fabricate(Group::Abteilung::Abteilungsleitung.name, group: camp.groups.first)

    camp
  end
  before { is_expected.to be_valid }

  context 'expected_participants' do
    it 'does not accept negative values' do
      subject.expected_participants_rover_f = -33
      is_expected.not_to be_valid
    end

    it 'does not accept non integer values' do
      subject.expected_participants_pio_m = 33.3
      is_expected.not_to be_valid
    end

    it 'accepts any positive integer' do
      subject.expected_participants_pio_m = 42
      is_expected.to be_valid
    end
  end

  context 'camp days' do
    it 'does not accept negative values' do
      subject.camp_days = -44
      is_expected.not_to be_valid
    end

    it 'accepts any positive integer' do
      subject.camp_days = 4
      is_expected.to be_valid
    end
  end

  context '#j_s_kind' do
    it 'accepts empty value' do
      subject.j_s_kind = nil
      is_expected.to be_valid

      subject.j_s_kind = ''
      is_expected.to be_valid
    end

    %w(j_s_child j_s_youth j_s_mixed).each do |kind|
      it "accepts '#{kind}'" do
        subject.j_s_kind = kind
        is_expected.to be_valid
      end
    end

    it 'does not accept any other string' do
      subject.j_s_kind = 'asdf'
      is_expected.not_to be_valid
    end
  end

  context '#application_possible' do
    it 'is possible if application dates are open and flag is set' do
      subject.application_opening_at = 5.days.ago
      subject.application_closing_at = 10.days.from_now

      expect(subject).not_to be_application_possible

      subject.participants_can_apply = true

      expect(subject).to be_application_possible

      subject.application_opening_at = 1.day.from_now

      expect(subject).not_to be_application_possible
    end
  end

  context 'abteilungsleitung assignement' do
    before do
      Group::Abteilung::Abteilungsleitung.destroy_all
    end

    %w(bund be bern).each do |group_name|
      context "camp above abteilung (:#{group_name})" do
        before { Fabricate(Group::Abteilung::Abteilungsleitung.name, group: groups(:schekka)) }

        it 'is not assigned' do
          camp = Fabricate(:pbs_camp, groups: [groups(group_name)])
          expect(camp.abteilungsleitung).to be_nil
        end
      end
    end

    %w(schekka sunnewirbu pegasus poseidon).each do |group_name|
      context "camp within abteilung (:#{group_name})" do
        it 'is not assigned if no abteilungsleitung is available' do
          camp = Fabricate(:pbs_camp, groups: [groups(group_name)])
          expect(camp.abteilungsleitung).to be_nil
        end

        it 'is not assigned if multiple abteilungsleitung' do
          Fabricate(Group::Abteilung::Abteilungsleitung.name, group: groups(:schekka))
          Fabricate(Group::Abteilung::Abteilungsleitung.name, group: groups(:schekka))

          camp = Fabricate(:pbs_camp, groups: [groups(group_name)])
          expect(camp.abteilungsleitung).to be_nil
        end

        it 'is assigned if single abteilungsleitung' do
          al = Fabricate(Group::Abteilung::Abteilungsleitung.name, group: groups(:schekka)).person
          camp = Fabricate(:pbs_camp, groups: [groups(group_name)])
          expect(camp.abteilungsleitung).to eq(al)
        end

        it 'is not assigned if single abteilungsleiter on update' do
          camp = Fabricate(:pbs_camp, groups: [groups(group_name)])
          Fabricate(Group::Abteilung::Abteilungsleitung.name, group: groups(:schekka))
          camp.save!
          expect(camp.abteilungsleitung).to be_nil
        end

        it 'is not overwritten if already assigned' do
          Fabricate(Group::Abteilung::Abteilungsleitung.name, group: groups(:schekka))
          al = Fabricate(Group::Abteilung::Abteilungsleitung.name, group: groups(:patria)).person

          camp = Fabricate(:pbs_camp, groups: [groups(group_name)], abteilungsleitung_id: al.id)
          expect(camp.abteilungsleitung).to eq(al)
        end
      end
    end
  end

  context 'advisor assignment info' do
    before do
      subject.coach_id = people(:al_berchtold).id
      subject.advisor_snow_security_id = people(:bulei).id
      subject.state = 'confirmed'
      subject.save!
    end

    it 'is not sent if nothing changed' do
      expect(Event::CampMailer).not_to receive(:advisor_assigned)
      subject.update!(location: 'Bern')
    end

    it 'is not sent if nothing changed even if id is set as string (as done by controller)' do
      expect(Event::CampMailer).not_to receive(:advisor_assigned)
      subject.update!(location: 'Bern', coach_id: people(:al_berchtold).id.to_s)
    end

    it 'is not sent if state set to created' do
      expect(Event::CampMailer).not_to receive(:advisor_assignedy)
      subject.update!(location: 'Bern', state: 'created')
    end

    it 'is not sent if state set to nil' do
      expect(Event::CampMailer).not_to receive(:advisor_assigned)
      subject.update!(location: 'Bern', state: nil)
    end

    it 'is not sent if state set to assignment_closed' do
      expect(Event::CampMailer).not_to receive(:advisor_assigned)
      subject.update!(location: 'Bern', state: 'assignment_closed')
    end

    it 'is not sent to freshly assigned if state is created' do
      subject.update!(state: 'created')
      expect(Event::CampMailer).not_to receive(:advisor_assigned)
      subject.update!(location: 'Bern', abteilungsleitung_id: people(:al_schekka).id, coach_id: people(:al_schekka).id)
    end

    it 'is sent to assigned if state changed from nil to assignment_closed' do
      subject.update!(state: nil)
      mail = double('mail', deliver_later: nil)
      expect(Event::CampMailer).to receive(:advisor_assigned).with(subject, people(:al_berchtold), 'coach', nil).and_return(mail)
      expect(Event::CampMailer).to receive(:advisor_assigned).with(subject, people(:bulei), 'advisor_snow_security', nil).and_return(mail)
      subject.update!(location: 'Bern', state: 'assignment_closed')
    end

    it 'is sent to assigned if state changed from created to confirmed' do
      subject.update!(state: 'created')
      mail = double('mail', deliver_later: nil)
      expect(Event::CampMailer).to receive(:advisor_assigned).with(subject, people(:al_berchtold), 'coach', nil).and_return(mail)
      expect(Event::CampMailer).to receive(:advisor_assigned).with(subject, people(:bulei), 'advisor_snow_security', nil).and_return(mail)
      expect(Event::CampMailer).to receive(:advisor_assigned).with(subject, people(:al_schekka), 'abteilungsleitung', nil).and_return(mail)
      subject.update!(location: 'Bern', state: 'confirmed', abteilungsleitung_id: people(:al_schekka).id)
    end

    it 'is sent to freshly assigned' do
      mail = double('mail', deliver_later: nil)
      expect(Event::CampMailer).to receive(:advisor_assigned).with(subject, people(:al_schekka), 'abteilungsleitung', nil).and_return(mail)
      expect(Event::CampMailer).to receive(:advisor_assigned).with(subject, people(:al_schekka), 'coach', nil).and_return(mail)
      subject.update!(location: 'Bern',
                      abteilungsleitung_id: people(:al_schekka).id,
                      coach_id: people(:al_schekka).id,
                      advisor_snow_security_id: nil)
    end

    %w(abteilungsleitung coach advisor_mountain_security advisor_snow_security advisor_water_security).each do |key|
      context "mail for #{key}" do
        it 'is sent' do
          subject.update!(state: nil, coach_id: '', advisor_snow_security_id: '')
          mail = double('mail', deliver_later: nil)

          person = Fabricate(Group::Woelfe::Wolf.name.to_sym, group: groups(:sunnewirbu)).person
          person.update_attribute(:first_name, key)
          expect(Event::CampMailer).to receive(:advisor_assigned).with(subject, person, key, nil)
                                                                 .and_return(mail)
          subject.send("#{key}_id=", person.id)
          subject.state = 'assignment_closed'
          subject.save!
        end
      end
    end

  end

  context 'camp created info' do
    before do
      subject.state = 'created'
      subject.save!
    end

    it 'is not sent if state stays created' do
      expect(Event::CampMailer).not_to receive(:camp_created)
      subject.update!(location: 'Bern')
    end

    it 'is not sent if state stays confirmed' do
      subject.update!(state: 'confirmed')
      expect(Event::CampMailer).not_to receive(:camp_created)
      subject.update!(location: 'Bern')
    end

    it 'is not sent if state set to nil' do
      expect(Event::CampMailer).not_to receive(:camp_created)
      subject.update!(location: 'Bern', state: nil)
    end

    it 'is not sent if state set from confirmed to assignment_closed' do
      subject.update!(state: 'confirmed')
      expect(Event::CampMailer).not_to receive(:camp_created)
      subject.update!(location: 'Bern', state: 'assignment_closed')
    end

    it 'is not sent if state set from assignment_closed to canceled' do
      subject.update!(state: 'assignment_closed')
      expect(Event::CampMailer).not_to receive(:camp_created)
      subject.update!(location: 'Bern', state: 'canceled')
    end

    it 'is not sent if state set from confirmed to created' do
      subject.update!(state: 'confirmed')
      expect(Event::CampMailer).not_to receive(:camp_created)
      subject.update!(location: 'Bern', state: 'created')
    end

    it 'is not sent if state set from canceled to closed' do
      subject.update!(state: 'canceled')
      expect(Event::CampMailer).not_to receive(:camp_created)
      subject.update!(location: 'Bern', state: 'closed')
    end

    context 'state set to confirmed' do
      [{ group_type: Group::Bund, role_type: Group::Bund::MitarbeiterGs },
       { group_type: Group::Kantonalverband, role_type: Group::Kantonalverband::Kantonsleitung },
       { group_type: Group::Region, role_type: Group::Region::Regionalleitung },
       { group_type: Group::Abteilung, role_type: Group::Abteilung::Abteilungsleitung },
       { group_type: Group::Biber, role_type: Group::Abteilung::Abteilungsleitung },
       { group_type: Group::Woelfe, role_type: Group::Abteilung::Abteilungsleitung },
       { group_type: Group::Pfadi, role_type: Group::Abteilung::Abteilungsleitung },
       { group_type: Group::Pio, role_type: Group::Abteilung::Abteilungsleitung },
       { group_type: Group::Pta, role_type: Group::Abteilung::Abteilungsleitung }
      ].each do |entry|

        context "camp on #{entry[:group_type].name.demodulize.downcase}" do
          let(:group) do
            if entry[:group_type].layer
              Fabricate(entry[:group_type].name)
            else
              Fabricate(entry[:group_type].name, parent: Fabricate(Group::Abteilung.name))
            end
          end
          let(:leader) do
            leader_group = entry[:group_type].layer ? group : group.parent
            Fabricate(entry[:role_type].name, group: leader_group).person
          end

          before do
            subject.update!(groups: [group])
          end

          it "is sent to #{entry[:role_type].name.demodulize.downcase}" do
            mail = double('mail', deliver_later: nil)
            expect(Event::CampMailer).to receive(:camp_created).with(subject, leader, nil).and_return(mail)
            subject.update!(location: 'Bern', state: 'confirmed')
          end
        end

      end
    end

  end

end
