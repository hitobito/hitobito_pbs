# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::RegisterMailer do

  before do
    SeedFu.quiet = true
    SeedFu.seed [Rails.root.join('db', 'seeds')]
  end

  let(:group) { event.groups.first }
  let(:event) { events(:top_event) }

  let(:person) do
    Fabricate(:person,
              email: 'fooo@example.com',
              reset_password_token: 'abc',
              salutation: 'lieber_pfadiname'
             )
  end
  let(:mail) { Event::RegisterMailer.register_login(person, group, event, 'abcdef') }

  context 'body' do
    subject { mail.body }

    it 'renders placeholders' do
      is_expected.to match(/Top Event/)
      is_expected.to match(/#{Regexp.escape person.salutation_value}/)
    end
  end
end
