#  Copyright (c) 2012-2024, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require "spec_helper"

describe GroupMembershipJob do
  let(:recipient) { people(:child) }
  let(:actuator) { people(:al_schekka) }
  let(:group) { groups(:schekka) }

  subject { GroupMembershipJob.new(recipient, actuator, group) }

  its(:parameters) do
    is_expected.to == {recipient_id: recipient.id,
                actuator_id: actuator.id,
                group_id: group.id,
                locale: I18n.locale.to_s}
  end

  it "sends email" do
    subject.perform
    expect(last_email).to be_present
    expect(last_email.body).to match(/Hallo #{recipient.greeting_name}.*#{group}/)
  end

  context "with locale" do
    after { I18n.locale = I18n.default_locale }

    subject do
      I18n.locale = :fr
      GroupMembershipJob.new(recipient, actuator, group)
    end

    it "sends localized email" do
      I18n.locale = :de
      subject.perform
      expect(last_email).to be_present
      expect(last_email.body).to match(/Salut #{recipient.greeting_name}.*#{group}/)
    end
  end
end
