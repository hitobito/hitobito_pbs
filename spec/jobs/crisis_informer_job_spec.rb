#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe CrisisInformerJob do

  before do
    @ref = @request.env['HTTP_REFERER'] = root_path
  end

  subject { CrisisInformerJob.new }

  it 'removes files and gets rescheduled' do
    subject.perform
    expect(subject.delayed_jobs).to be_exists
  end

  it 'sends reminder mail to incompleted crises' do
    crises(:bulei_bund).update!(created_at: 4.days.ago)
    crises(:acknowledged).update!(created_at: 8.days.ago)

    subject.perform_internal

    expect(ActionMailer::Base.deliveries.count).to eq(2)
    expect(last_email.subject).to match(/Krise wurde ausgelöst/)
    expect(last_email.body).to match(/Auf der Abteilung test wurde eine Krise durch/)
    expect(last_email.body).to match(/das Krisenteam der Bundesebene ausgelöst/)
  end

end
