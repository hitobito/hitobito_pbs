#  Copyright (c) 2012-2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# == Schema Information
#
# Table name: events
#
#  id                                :integer          not null, primary key
#  type                              :string(255)
#  name                              :string(255)      not null
#  number                            :string(255)
#  motto                             :string(255)
#  cost                              :string(255)
#  maximum_participants              :integer
#  contact_id                        :integer
#  description                       :text(65535)
#  location                          :text(65535)
#  application_opening_at            :date
#  application_closing_at            :date
#  application_conditions            :text(65535)
#  kind_id                           :integer
#  state                             :string(60)
#  priorization                      :boolean          default(FALSE), not null
#  requires_approval                 :boolean          default(FALSE), not null
#  created_at                        :datetime
#  updated_at                        :datetime
#  participant_count                 :integer          default(0)
#  application_contact_id            :integer
#  external_applications             :boolean          default(FALSE)
#  applicant_count                   :integer          default(0)
#  teamer_count                      :integer          default(0)
#  signature                         :boolean
#  signature_confirmation            :boolean
#  signature_confirmation_text       :string(255)
#  creator_id                        :integer
#  updater_id                        :integer
#  applications_cancelable           :boolean          default(FALSE), not null
#  training_days                     :decimal(12, 1)
#  tentative_applications            :boolean          default(FALSE), not null
#  language_de                       :boolean          default(FALSE), not null
#  language_fr                       :boolean          default(FALSE), not null
#  language_it                       :boolean          default(FALSE), not null
#  language_en                       :boolean          default(FALSE), not null
#  express_fee                       :string
#  requires_approval_abteilung       :boolean          default(FALSE), not null
#  requires_approval_region          :boolean          default(FALSE), not null
#  requires_approval_kantonalverband :boolean          default(FALSE), not null
#  requires_approval_bund            :boolean          default(FALSE), not null
#  expected_participants_wolf_f      :integer
#  expected_participants_wolf_m      :integer
#  expected_participants_pfadi_f     :integer
#  expected_participants_pfadi_m     :integer
#  expected_participants_pio_f       :integer
#  expected_participants_pio_m       :integer
#  expected_participants_rover_f     :integer
#  expected_participants_rover_m     :integer
#  expected_participants_leitung_f   :integer
#  expected_participants_leitung_m   :integer
#  canton                            :string(2)
#  coordinates                       :string
#  altitude                          :string
#  emergency_phone                   :string
#  landlord                          :text
#  landlord_permission_obtained      :boolean          default(FALSE), not null
#  j_s_kind                          :string
#  j_s_security_snow                 :boolean          default(FALSE), not null
#  j_s_security_mountain             :boolean          default(FALSE), not null
#  j_s_security_water                :boolean          default(FALSE), not null
#  participants_can_apply            :boolean          default(FALSE), not null
#  participants_can_cancel           :boolean          default(FALSE), not null
#  al_present                        :boolean          default(FALSE), not null
#  al_visiting                       :boolean          default(FALSE), not null
#  al_visiting_date                  :date
#  coach_visiting                    :boolean          default(FALSE), not null
#  coach_visiting_date               :date
#  coach_confirmed                   :boolean          default(FALSE), not null
#  local_scout_contact_present       :boolean          default(FALSE), not null
#  local_scout_contact               :text
#  camp_submitted                    :boolean          default(FALSE), not null
#  camp_reminder_sent                :boolean          default(FALSE), not null
#  paper_application_required        :boolean          default(FALSE), not null
#  lagerreglement_applied            :boolean          default(FALSE), not null
#  kantonalverband_rules_applied     :boolean          default(FALSE), not null
#  j_s_rules_applied                 :boolean          default(FALSE), not null
#  required_contact_attrs            :text
#  hidden_contact_attrs              :text
#  display_booking_info              :boolean          default(TRUE), not null
#  bsv_days                          :decimal(6, 2)
#


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

  context 'automatic abteilungsleitung assignement' do
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
      subject.update!(location: 'Bern', coach_id: people(:al_schekka).id)
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
      subject.update!(location: 'Bern', state: 'confirmed')
    end

    it 'is sent to freshly assigned' do
      mail = double('mail', deliver_later: nil)
      expect(Event::CampMailer).to receive(:advisor_assigned).with(subject, people(:al_schekka), 'coach', nil).and_return(mail)
      subject.update!(location: 'Bern',
                      coach_id: people(:al_schekka).id,
                      advisor_snow_security_id: nil)
    end

    it 'is not sent if freshly assigned does not have email set' do
      people(:al_schekka).update(email: nil)
      expect(Event::CampMailer).not_to receive(:advisor_assigned)
      subject.update!(location: 'Bern',
                      coach_id: people(:al_schekka).id,
                      advisor_snow_security_id: nil)
    end

    %w(coach advisor_mountain_security advisor_snow_security advisor_water_security).each do |key|
      context "mail for #{key}" do
        it 'is sent' do
          subject.update!(state: nil, coach_id: '', advisor_snow_security_id: '')
          mail = double('mail', deliver_later: nil)

          person = Fabricate(Group::Woelfe::Wolf.name.to_sym, group: groups(:sunnewirbu)).person
          person.update(first_name: key)
          expect(Event::CampMailer).to receive(:advisor_assigned).with(subject, person, key, nil)
                                                                 .and_return(mail)
          subject.send("#{key}_id=", person.id)
          subject.state = 'assignment_closed'
          subject.save!
        end
      end
    end

  end

  context 'abteilungsleitung assignment info' do
    before do
      subject.state = 'confirmed'
      subject.save!
    end

    it 'is not sent if not set' do
      expect(Event::CampMailer).not_to receive(:advisor_assigned)
      subject.update!(location: 'Bern')
    end

    it 'is not sent if nothing changed' do
      subject.update!(abteilungsleitung_id: people(:al_berchtold).id)

      expect(Event::CampMailer).not_to receive(:advisor_assigned)
      subject.update!(location: 'Bern')
    end

    it 'is sent if abteilungsleitung changed' do
      mail = double('mail', deliver_later: nil)
      expect(Event::CampMailer).to receive(:advisor_assigned).
                                   with(subject, people(:al_berchtold), 'abteilungsleitung', nil).
                                   and_return(mail)
      subject.update!(location: 'Bern',
                      abteilungsleitung_id: people(:al_berchtold).id)
    end

    [{ from: nil, to: :created },
     { from: :created, to: :confirmed },
     { from: :confirmed, to: :assignment_closed },
     { from: :assignment_closed, to: :canceled },
     { from: :canceled, to: :closed },
     { from: :confirmed, to: :created }].each do |state_change|
      it "is not sent if abteilungsleitung did not change and state changed from #{state_change[:from]} to #{state_change[:to]}" do
        subject.update!(state: state_change[:from],
                        abteilungsleitung_id: people(:al_berchtold).id)

        expect(Event::CampMailer).not_to receive(:advisor_assigned)
        subject.update!(location: 'Bern', state: state_change[:to])
      end

      it "is sent if abteilungsleitung changed and state changed from #{state_change[:from]} to #{state_change[:to]}" do
        subject.update!(state: state_change[:from])

        mail = double('mail', deliver_later: nil)
        expect(Event::CampMailer).to receive(:advisor_assigned).
                                     with(subject, people(:al_berchtold), 'abteilungsleitung', nil).
                                     and_return(mail)

        subject.update!(location: 'Bern', state: state_change[:to],
                        abteilungsleitung_id: people(:al_berchtold).id)
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

      it "is sent only once" do
        group = Fabricate(Group::Abteilung.name)
        leader = Fabricate(Group::Abteilung::Abteilungsleitung.name, group: group).person
        Role.create(group: group, person: leader, type: Group::Abteilung::Adressverwaltung.sti_name)
        subject.update!(groups: [group])
        mail = double('mail', deliver_later: nil)
        expect(Event::CampMailer).to receive(:camp_created).with(subject, leader, nil).and_return(mail).once
        subject.update!(location: 'Bern', state: 'confirmed')
      end
    end

  end

  context 'reset coach confirmed' do
    it 'sets to false if changed' do
      subject.update!(coach_id: people(:bulei).id)
      subject.update!(coach_confirmed: true)

      subject.update!(coach_id: people(:al_berchtold).id)
      expect(subject.coach_confirmed).to eq false
    end

    it 'keeps if unchanged' do
      subject.update!(coach_id: people(:bulei).id)
      subject.update!(coach_confirmed: true)

      subject.update!(altitude: 22)
      expect(subject.coach_confirmed).to eq true
    end
  end

  context 'camp days' do
    it 'counts dates without finish at as one day' do
      subject.dates.first.update!(finish_at: nil)
      expect(subject.camp_days).to eq 1
    end

    it 'counts number of dates given by event date' do
      date = subject.dates.first
      finish_at = date.start_at + 5.days
      date.update!(finish_at: finish_at)
      expect(subject.camp_days).to eq 6
    end

    it 'accumulates days of multiple event dates' do
      date1 = subject.dates.first
      finish_at = date1.start_at + 5.days
      date1.update!(finish_at: finish_at)
      Fabricate(:event_date,
                event: subject,
                start_at: Date.new(2019, 3, 1),
                finish_at: Date.new(2019, 3, 3))
      subject.reload

      expect(subject.camp_days).to eq 9
    end
  end

  context 'camp leader checkpoints' do
    it 'resetts all checkpoints to false when camp leader is changed' do
      subject.leader_id = people(:bulei).id
      subject.save!

      Event::Camp::LEADER_CHECKPOINT_ATTRS.each do |c|
        subject.update(c => true)
      end

      subject.leader_id = people(:al_schekka).id
      subject.save!

      subject.reload

      Event::Camp::LEADER_CHECKPOINT_ATTRS.each do |c|
        expect(subject.send(c)).to be false
      end

    end
  end

  context 'camp application' do

    subject { events(:schekka_camp) }

    it 'is not valid if camp_submitted and required value missing' do
      updates(subject)
      required_attrs_for_camp_application.each do |a, v|
        subject.reload
        subject.camp_submitted_at = Time.zone.now.to_date - 1.day
        expect(subject).to be_valid
        clear_attribute(subject, a)
        expect(subject).not_to be_valid
        expect(subject.errors.full_messages.first).to match(/muss ausgefüllt werden/)
      end
    end

    it 'is valid if camp_submitted and all required values are present' do
      updates(subject)
      subject.camp_submitted_at = Time.zone.now.to_date - 1.day
      expect(subject).to be_valid
    end

    it 'is valid if camp_submitted and all required values are present, without advisor security' do
      updates(subject, false)
      subject.camp_submitted_at = Time.zone.now.to_date - 1.day
      expect(subject).to be_valid
    end

    def required_attrs_for_camp_application
      advisor_attributes.merge(
      { canton: 'be',
        location: 'foo',
        coordinates: '42',
        altitude: '1001',
        emergency_phone: '080011',
        landlord: 'georg',
        coach_confirmed: true,
        lagerreglement_applied: true,
        kantonalverband_rules_applied: true,
        j_s_rules_applied: true,
        expected_participants_pio_f: 3
      })
    end

    def advisor_attributes
      { coach_id: Fabricate(:person).id,
        leader_id: Fabricate(:person).id,
      }.merge(advisor_security_attributes)
    end

    def advisor_security_attributes
      { advisor_snow_security_id: [:j_s_security_snow, Fabricate(:person).id],
        advisor_mountain_security_id: [:j_s_security_mountain, Fabricate(:person).id],
        advisor_water_security_id: [:j_s_security_water, Fabricate(:person).id]
      }
    end

    def updates(camp, with_advisor_security = true)
      required_attrs_for_camp_application.each do |a, v|
        unless !with_advisor_security && advisor_security_attributes.include?(a)
          attrs = {}
          if v.is_a?(Array)
            attrs[v.first] = true
            attrs[a] = v.second
          else
            attrs[a] = v
          end
          camp.update!(attrs)
        end
      end
    end

    def clear_attribute(camp, attr)
      if advisor_attributes.include?(attr)
        camp.coach_confirmed = false
        person_id = camp.send(attr)
        camp.participations.find_by(person_id: person_id).destroy!
      else
        value = camp.send(attr)
        new_value = value.is_a?(TrueClass) ? false : nil
        camp.send("#{attr}=", new_value)
      end
    end
  end

  context 'hierarchies, a camp' do
    subject { events(:bund_camp) }

    it 'may belong to a super_camp' do
      is_expected.to respond_to :super_camp
    end

    it 'may have sub_camps' do
      is_expected.to respond_to :sub_camps
    end

    it 'can be marked as having sub_camps' do
      is_expected.to respond_to :allow_sub_camps
      is_expected.to respond_to :allow_sub_camps=
    end

    context 'attaching and detaching' do

      let(:super_camp) { events(:bund_supercamp) }
      let(:sub_camp) { events(:schekka_camp) }

      it 'may only be attached to a super-camp that allows it' do
        super_camp.update(allow_sub_camps: false)
        sub_camp.parent_id = super_camp.id

        expect(sub_camp).to_not be_valid
      end

      it 'may only be attached to a super-camp in created state' do
        super_camp.update(state: 'confirmed')
        sub_camp.parent_id = super_camp.id

        expect(sub_camp).to_not be_valid
      end

      it 'may be detached from a super-camp at any time' do
        sub_camp.update(parent_id: super_camp.id)
        super_camp.update(state: 'confirmed', allow_sub_camps: false)
        sub_camp.parent_id = nil

        expect(sub_camp).to be_valid
      end

    end

    context 'allowed to have sub_camps' do
      before { subject.update(allow_sub_camps: true) }

      it 'can have sub_camps' do
        expect do
          subject.sub_camps << events(:schekka_camp)
        end.to change { subject.sub_camps.size }.by 1
      end

      it 'cannot be deleted if sub_camps are attached' do
        subject.sub_camps << events(:schekka_camp)
        expect do
          subject.destroy
          is_expected.to_not be_valid
        end.to_not raise_exception
      end
    end

    context 'not allowed to have sub_camps' do
      before { subject.update(allow_sub_camps: false) }

      it 'is invalid if sub_camps are added' do
        sub_camp = events(:schekka_camp)
        expect do
          subject.sub_camps << sub_camp

          is_expected.to_not be_valid
          expect(sub_camp).to_not be_valid
        end.to_not change { subject.reload.sub_camps.size }
      end

      it 'does not have sub_camps' do
        expect(subject.sub_camps).to be_none
      end

      it 'can be deleted' do
        expect do
          subject.destroy
        end.to change { described_class.count }.by(-1)
      end
    end

    context 'having sub_camps' do
      before do
        subject.update(allow_sub_camps: true)
        subject.sub_camps << events(:schekka_camp)
      end

      it 'may not loose the allow_sub_camps-flag' do
        subject.allow_sub_camps = false

        is_expected.to_not be_valid
      end
    end
  end

end
