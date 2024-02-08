# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe CleanupCourseApprovalsJob do
  include ActiveJob::TestHelper

  let(:job) { CleanupCourseApprovalsJob.new }
  
  context 'when configured' do
    it 'runs cleanup job' do
      job.perform
    end
  end
end