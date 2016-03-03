# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::CampReminderJob do

  let(:job) { Event::CampReminderJob.new }

  it 'is scheduled at 3 am' do
    job.schedule
    expect(job.delayed_jobs.count).to eq(1)
    delayed = job.delayed_jobs.first
    expect(delayed.run_at.hour).to eq(3)
  end

  it 'contains all upcoming camps' do
    now = Time.zone.now
    at_span = Fabricate(:pbs_camp, canton: 'be', state: 'confirmed')
    at_span.dates = [Fabricate(:event_date, event: at_span, start_at: now + Event::CampReminderJob::SPAN_NATIONAL)]
    early = Fabricate(:pbs_camp, canton: 'be', state: 'confirmed')
    early.dates = [Fabricate(:event_date, event: early, start_at: now + 1.week)]
    abroad = Fabricate(:pbs_camp, canton: Event::Camp::ABROAD_CANTON, state: 'confirmed')
    abroad.dates = [Fabricate(:event_date, event: abroad, start_at: now + Event::CampReminderJob::SPAN_NATIONAL + 1.week)]
    after_span = Fabricate(:pbs_camp, canton: 'be', state: 'confirmed')
    after_span.dates = [Fabricate(:event_date, event: after_span, start_at: now + Event::CampReminderJob::SPAN_NATIONAL + 1.day)]
    submitted = fabricate_pbs_camp(canton: 'be', state: 'confirmed', camp_submitted: true)
    submitted.dates = [Fabricate(:event_date, event: submitted, start_at: now + 1.week)]
    created = Fabricate(:pbs_camp, canton: 'be', state: 'created')
    created.dates = [Fabricate(:event_date, event: created, start_at: now + 1.week)]
    reminded = Fabricate(:pbs_camp, canton: 'be', state: 'confirmed', camp_reminder_sent: true)
    reminded.dates = [Fabricate(:event_date, event: reminded, start_at: now + 1.week)]

    expect(job.camps_to_remind).to match_array([at_span, early, abroad])
  end

  it 'sends reminder for all leaders and coaches' do
    now = Time.zone.now
    at_span = Fabricate(:pbs_camp, canton: 'be', state: 'confirmed')
    at_span.dates = [Fabricate(:event_date, event: at_span, start_at: now + Event::CampReminderJob::SPAN_NATIONAL)]
    l1 = Fabricate(:pbs_participation, event: at_span, roles: [Fabricate(Event::Camp::Role::Leader.name)])
    l2 = Fabricate(:pbs_participation, event: at_span, roles: [Fabricate(Event::Camp::Role::Leader.name)])
    Fabricate(:pbs_participation, event: at_span, roles: [Fabricate(Event::Camp::Role::AssistantLeader.name)])

    abroad = Fabricate(:pbs_camp, canton: Event::Camp::ABROAD_CANTON, state: 'confirmed')
    abroad.dates = [Fabricate(:event_date, event: abroad, start_at: now + Event::CampReminderJob::SPAN_ABROAD)]
    c1 = Fabricate(:pbs_participation, event: abroad, roles: [Fabricate(Event::Camp::Role::Coach.name)])
    Fabricate(:pbs_participation, event: abroad, roles: [Fabricate(Event::Camp::Role::Participant.name)])

    no_roles = Fabricate(:pbs_camp, canton: 'be', state: 'confirmed')
    no_roles.dates = [Fabricate(:event_date, event: no_roles, start_at: now + 1.week)]
    Fabricate(:pbs_participation, event: no_roles, roles: [Fabricate(Event::Camp::Role::Participant.name)])

    mail = double('mail')
    expect(mail).to receive(:deliver_now).at_least(:once)
    expect(Event::CampMailer).to receive(:remind).with(at_span, l1.person).and_return(mail)
    expect(Event::CampMailer).to receive(:remind).with(at_span, l2.person).and_return(mail)
    expect(Event::CampMailer).to receive(:remind).with(abroad, c1.person).and_return(mail)

    job.perform_internal

    expect(at_span.reload.camp_reminder_sent).to be true
    expect(abroad.reload.camp_reminder_sent).to be true
    expect(no_roles.reload.camp_reminder_sent).to be false
  end

  it 'sets camp_reminder_sent for all processed' do
    mail = double('mail')
    expect(mail).to receive(:deliver_now).at_least(:once)
    expect(Event::CampMailer).to receive(:remind).and_return(mail).at_least(:once)

    now = Time.zone.now
    at_span = Fabricate(:pbs_camp, canton: 'be', state: 'confirmed')
    at_span.dates = [Fabricate(:event_date, event: at_span, start_at: now + Event::CampReminderJob::SPAN_NATIONAL)]
    Fabricate(:pbs_participation, event: at_span, roles: [Fabricate(Event::Camp::Role::Leader.name)])

    abroad = Fabricate(:pbs_camp, canton: Event::Camp::ABROAD_CANTON, state: 'confirmed')
    abroad.dates = [Fabricate(:event_date, event: abroad, start_at: now + Event::CampReminderJob::SPAN_ABROAD)]
    Fabricate(:pbs_participation, event: abroad, roles: [Fabricate(Event::Camp::Role::Coach.name)])

    after_span = Fabricate(:pbs_camp, canton: 'be', state: 'confirmed')
    after_span.dates = [Fabricate(:event_date, event: after_span, start_at: now + Event::CampReminderJob::SPAN_NATIONAL + 1.day)]
    Fabricate(:pbs_participation, event: after_span, roles: [Fabricate(Event::Camp::Role::Leader.name)])

    job.perform_internal

    expect(at_span.reload.camp_reminder_sent).to be true
    expect(abroad.reload.camp_reminder_sent).to be true
    expect(after_span.reload.camp_reminder_sent).to be false
  end

  def fabricate_pbs_camp(overrides={})
    if overrides[:camp_submitted]
      overrides = required_attrs_for_camp_submit.
        merge(overrides)
    end
    Fabricate(:pbs_camp, overrides)
  end

  def required_attrs_for_camp_submit
    { canton: 'be',
      location: 'foo',
      coordinates: '42',
      altitude: '1001',
      emergency_phone: '080011',
      landlord: 'georg',
      j_s_kind: 'j_s_child',
      coach_confirmed: true,
      lagerreglement_applied: true,
      kantonalverband_rules_applied: true,
      j_s_rules_applied: true,
      expected_participants_pio_f: 3,
      coach_id: Fabricate(:person).id,
      leader_id: Fabricate(:person).id
    }
  end

end
