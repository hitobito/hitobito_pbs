# frozen_string_literal: true

require 'spec_helper'

describe Alumni::Invitations do
  around do |example|
    freeze_time { example.run }
  end

  context '#time_range' do
    after { Settings.reload! }

    it 'begins 6 months ago' do
      expect(subject.time_range.begin).to eq 6.months.ago
    end

    it 'ends 3 months ago' do
      expect(subject.time_range.end).to eq 3.months.ago
    end

    it 'is configurable' do
      Settings.alumni.invitation.role_deleted_after_ago = 'P6Y'
      Settings.alumni.invitation.role_deleted_before_ago = 'P7D'

      expect(subject.time_range.begin).to eq 6.years.ago
      expect(subject.time_range.end).to eq 7.days.ago
    end
  end

  context '#type' do
    it 'is :invitation' do
      expect(subject.type).to eq :invitation
    end
  end

  context '#relevant_roles' do
    def make_role(deleted_at: nil, alumni_invitation_processed_at: nil)
      Fabricate(
        'Group::Pfadi::Pfadi',
        group: groups(:pegasus),
        created_at: 1.year.ago,
        deleted_at: deleted_at,
        alumni_invitation_processed_at: alumni_invitation_processed_at
      )
    end

    it 'includes roles with deleted_at in time_range' do
      older_role = make_role(deleted_at: 6.months.ago)
      newer_role = make_role(deleted_at: 3.months.ago)

      expect(subject.relevant_roles).to include(older_role, newer_role)
    end

    it 'excludes roles with deleted_at not in time_range' do
      too_old_role = make_role(deleted_at: 6.months.ago - 1.minute)
      too_new_role = make_role(deleted_at: 3.months.ago + 1.minute)

      expect(subject.relevant_roles).not_to include(too_old_role, too_new_role)
    end

    it 'excludes roles with deleted_at nil' do
      current_role = make_role(deleted_at: nil)

      expect(subject.relevant_roles).not_to include(current_role)
    end

    it 'includes roles with alumni_invitation_processed_at nil' do
      unprocessed_role = make_role(deleted_at: 4.months.ago, alumni_invitation_processed_at: nil)

      expect(subject.relevant_roles).to include(unprocessed_role)
    end

    it 'excludes roles with alumni_invitation_processed_at set' do
      processed_role = make_role(deleted_at: 4.months.ago,
                                 alumni_invitation_processed_at: 1.second.ago)

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
                                                         :invitation).and_return(invitation_double)
        expect(invitation_double).to receive(:process)
      end

      subject.process
    end
  end
end
