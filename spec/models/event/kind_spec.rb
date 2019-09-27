# encoding: utf-8
#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::Kind do

  it 'validates confirmation_name not empty when confirmations allowed' do
    subject.can_have_confirmations = true
    subject.confirmation_name = nil
    expect(subject).to have(1).error_on(:confirmation_name)
    subject.confirmation_name = 'basiskurs'
    expect(subject).to have(0).errors_on(:pbs_number)
  end

end
