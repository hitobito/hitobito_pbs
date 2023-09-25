# frozen_string_literal: true

require 'spec_helper'

describe Alumni::Reminders do
  around do |example|
    freeze_time { example.run }
  end

  context '#time_range' do
    after { Settings.reload! }

    it 'begins open ended' do
      expect(subject.time_range.begin).to eq nil
    end

    it 'ends 6 months ago' do
      expect(subject.time_range.end).to eq 6.months.ago
    end

    it 'is configurable' do
      Settings.alumni.reminder.role_deleted_before_ago = 'PT30S'

      expect(subject.time_range.end).to eq 30.seconds.ago
    end
  end

  context '#type' do
    it 'is :reminder' do
      expect(subject.type).to eq :reminder
    end
  end

  context '#relevant_roles' do
    def make_role(deleted_at: nil, alumni_reminder_processed_at: nil)
      Fabricate(
        'Group::Pfadi::Pfadi',
        group: groups(:pegasus),
        created_at: 10.years.ago,
        deleted_at: deleted_at,
        alumni_reminder_processed_at: alumni_reminder_processed_at
      )
    end

    it 'includes roles with deleted_at in time_range' do
      older_role = make_role(deleted_at: 100.months.ago)
      newer_role = make_role(deleted_at: 6.months.ago)

      expect(subject.relevant_roles).to include(older_role, newer_role)
    end

    it 'excludes roles with deleted_at not in time_range' do
      too_new_role = make_role(deleted_at: 6.months.ago + 1.minute)

      expect(subject.relevant_roles).not_to include(too_new_role)
    end

    it 'excludes roles with deleted_at nil' do
      current_role = make_role(deleted_at: nil)

      expect(subject.relevant_roles).not_to include(current_role)
    end

    it 'includes roles with alumni_reminder_processed_at nil' do
      unprocessed_role = make_role(deleted_at: 10.months.ago, alumni_reminder_processed_at: nil)

      expect(subject.relevant_roles).to include(unprocessed_role)
    end

    it 'excludes roles with alumni_reminder_processed_at set' do
      processed_role = make_role(deleted_at: 4.months.ago,
                                 alumni_reminder_processed_at: 1.second.ago)

      expect(subject.relevant_roles).not_to include(processed_role)
    end

  end

  context '#process' do
    it 'calls Alumni::Invitation#process for each relevant role' do
      role1 = instance_double('Role')
      role2 = instance_double('Role')
      allow(subject).to receive(:relevant_roles).and_return([role1, role2])

      [role1, role2].each do |role|
        invitation_double = instance_double('Alumni::Invitation')
        expect(Alumni::Invitation).to receive(:new).with(role,
                                                         :reminder).and_return(invitation_double)
        expect(invitation_double).to receive(:process)
      end

      subject.process
    end
  end
end
