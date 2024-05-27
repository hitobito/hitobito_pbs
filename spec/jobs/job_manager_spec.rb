# frozen_string_literal: true

#  Copyright (c) 2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe JobManager do
  subject(:jobs) do
    described_class.wagon_jobs.map(&:name)
  end

  it 'knows about jobs of the wagon' do
    expect(jobs).to have(3).items
  end

  %w(
    AlumniInvitationsJob
    Event::ApprovalCleanupJob
    Event::CampReminderJob
  ).each do |job_class|
    it "has #{job_class} in the list of jobs" do
      expect(jobs).to include(job_class)
    end
  end
end
