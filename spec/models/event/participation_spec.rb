# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::Participation do
  let(:event) { events(:top_course) }

  context 'validations' do
    context 'presence of j_s_data_sharing_accepted' do
      let(:participation) { Fabricate.build(:pbs_participation, j_s_data_sharing_accepted_at: nil, event: event) }

      [Event::Camp, Event::Campy, Event::Course].each do |js_event|
        %w(j_s_child j_s_youth j_s_mixed).each do |j_s_kind|
          it "is validated for event.type=#{js_event.name} and event.j_s_kind=#{j_s_kind}" do
            event.j_s_kind =  j_s_kind
            expect(participation).to be_invalid
            expect(participation.errors.attribute_names).to include(:j_s_data_sharing_accepted)
          end
        end

        it "is not validated for event.type=#{js_event.name} and event.j_s_kind=none" do
          event.j_s_kind = 'none'
          expect(participation).to be_valid
        end
      end
    end
  end

  context '#approvers' do
    it 'is empty if no application exists' do
      expect(Fabricate(:pbs_participation, event: event).approvers).to be_empty
    end

    it 'returns people that approved or rejected participation' do
      participation = Fabricate(:pbs_participation,
                                event: event,
                                application: Event::Application.new(priority_1: event))
      participation.application.approvals.create!(layer: 'abteilung',
                                                  approved: true,
                                                  approver: people(:al_schekka),
                                                  comment: 'yup',
                                                  current_occupation: 'chief',
                                                  current_level: 'junior',
                                                  occupation_assessment: 'good',
                                                  strong_points: 'strong',
                                                  weak_points: 'weak')
      participation.application.approvals.create!(layer: 'region',
                                                  rejected: true,
                                                  approver: people(:bulei),
                                                  comment: 'yup',
                                                  current_occupation: 'chief',
                                                  current_level: 'junior',
                                                  occupation_assessment: 'good',
                                                  strong_points: 'strong',
                                                  weak_points: 'weak')
      participation.application.approvals.create!(layer: 'kantonalverband')

      expect(participation.approvers).to have(2).items
      expect(participation.approvers).to include(people(:bulei), people(:al_schekka))
    end
  end

  context '#j_s_data_sharing_accepted' do
    it 'is false if j_s_data_sharing_accepted_at is nil' do
      expect(Fabricate(:pbs_participation, j_s_data_sharing_accepted_at: nil).j_s_data_sharing_accepted).to eq false
    end

    it 'is true if j_s_data_sharing_accepted is set' do
      expect(Fabricate(:pbs_participation, j_s_data_sharing_accepted_at: Time.zone.now).j_s_data_sharing_accepted).to eq true
    end
  end

  context '#j_s_data_sharing_accepted=' do
    context 'with argument `true`' do
      it 'sets j_s_data_sharing_accepted_at' do
        participation = Fabricate(:pbs_participation, j_s_data_sharing_accepted_at: nil)
        expect { participation.j_s_data_sharing_accepted = true }.to change { participation.j_s_data_sharing_accepted_at }.from(nil)
      end

      it 'does not change j_s_data_sharing_accepted_at if it is already set' do
        participation = Fabricate(:pbs_participation, j_s_data_sharing_accepted_at: 1.year.ago)
        expect { participation.j_s_data_sharing_accepted = true }.not_to change { participation.j_s_data_sharing_accepted_at }
      end
    end

    it 'with argument `false` does not change j_s_data_sharing_accepted_at' do
      participation = Fabricate(:pbs_participation, j_s_data_sharing_accepted_at: nil)
      expect { participation.j_s_data_sharing_accepted = false }.not_to change { participation.j_s_data_sharing_accepted_at }.from(nil)

      participation.j_s_data_sharing_accepted_at =  Time.zone.now
      expect { participation.j_s_data_sharing_accepted = false }.not_to change { participation.j_s_data_sharing_accepted_at }
    end
  end

  context 'verifying participatable counts' do

    before { event.refresh_participant_counts! } # to create existing participatiots

    def create_participant(state)
      participation = Fabricate(:pbs_participation, event: event, state: state, canceled_at: Date.today)
      participation.roles.create!(type: event.participant_types.first.name)
    end

    context 'simple' do
      let(:event) { events(:top_event) }

      it "creating application does increase event#application_count" do
        expect { create_participant(nil) }.to change { event.reload.applicant_count }.by(1)
      end
    end

    context 'course' do
      %w(tentative canceled rejected).each do |state|
        it "creating #{state} application does not increase event#applicant_count" do
          expect { create_participant(state) }.not_to change { event.reload.applicant_count }
        end
      end

      %w(applied assigned attended absent).each do |state|
        it "creating #{state} application does increase event#application_count" do
          expect { create_participant(state) }.to change { event.reload.applicant_count }.by(1)
        end
      end
    end

    context 'camp' do
      let(:event) { events(:schekka_camp) }

      %w(canceled).each do |state|
        it "creating #{state} application does not increase event#applicant_count" do
          expect { create_participant(state) }.not_to change { event.reload.applicant_count }
        end
      end

      %w(applied_electronically assigned absent).each do |state|
        it "creating #{state} application does increase event#application_count" do
          expect { create_participant(state) }.to change { event.reload.applicant_count }.by(1)
        end
      end

      it 'assigns participant directly if no paper application required' do
        p = Fabricate(:pbs_participation, event: event, person: Fabricate(:person))
        p.roles.build(type: Event::Camp::Role::Participant.sti_name)
        p.save!
        expect(p.state).to eq('assigned')
      end

      it 'assigns leader directly if paper application required' do
        event.update!(paper_application_required: true)
        p = Fabricate(:pbs_participation, event: event, person: Fabricate(:person))
        p.roles.build(type: Event::Camp::Role::Helper.sti_name)
        p.save!
        expect(p.state).to eq('assigned')
      end

      it 'set participant applied_electronically if paper application required' do
        event.update!(paper_application_required: true)
        p = Fabricate(:pbs_participation, event: event, person: Fabricate(:person))
        p.roles.build(type: Event::Camp::Role::Participant.sti_name)
        p.save!
        expect(p.state).to eq('applied_electronically')
      end
    end

  end

  context '#bsv_days' do
    let(:participation) { Fabricate(:pbs_participation, event: event) }

    it 'is valid when empty' do
      expect(participation).to be_valid
    end

    it 'is valid when multiple of 0.5' do
      participation.bsv_days = 3.5
      expect(participation).to be_valid
    end

    it 'is not valid when negative' do
      participation.bsv_days = -1
      expect(participation).not_to be_valid
    end

    it 'is not valid when not multiple of 0.5' do
      participation.bsv_days = 2.25
      expect(participation).not_to be_valid
    end

    it 'is not valid when course has bsv_days set' do
      participation.event.bsv_days = 3
      participation.bsv_days = nil
      participation.state = :attended
      expect(participation).not_to be_valid
    end
  end

  context 'notification if person is on black list' do
    let!(:person)      { Fabricate(:person, first_name: 'foo', last_name: 'bar') }
    let(:last_email)  { ActionMailer::Base.deliveries.last }

    before do
      SeedFu.quiet = true
      SeedFu.seed [Rails.root.join('db', 'seeds')]
      allow_any_instance_of(BlackListMailer).to receive(:recipients).and_return('test@test.com')
    end

    it 'is sent on participation creation with black list person' do
      Fabricate(:black_list, first_name: 'foo', last_name: 'bar')

      expect do
        Event::Participation.create(event: event, person: person, j_s_data_sharing_accepted_at: Time.zone.now)
      end.to change { ActionMailer::Base.deliveries.count }.by(1)

      expect(last_email.body).to include(person.full_name)
      expect(last_email.body).to include(event.name)
    end

    it 'is not sent on participation creation if person is not blacklisted' do
      expect do
        Event::Participation.create(event: event, person: person)
      end.not_to change { ActionMailer::Base.deliveries.count }
    end

  end

end
