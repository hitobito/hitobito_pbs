#  Copyright (c) 2012-2024, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe Event::RegisterMailer do
  let(:group) { event.groups.first }
  let(:event) { events(:top_event) }

  let(:person) do
    Fabricate(:person,
      email: "fooo@example.com",
      reset_password_token: "abc",
      salutation: "lieber_pfadiname")
  end
  let(:mail) { Event::RegisterMailer.register_login(person, group, event, "abcdef") }

  context "body" do
    before :all do
      template = CustomContent.find_or_create_by key: described_class::CONTENT_REGISTER_LOGIN
      template.update!(
        label: "Anlass: Temporäres Login senden",
        subject: "Anmeldelink für Anlass",
        body: "{recipient-name-with-salutation}<br/><br/>" \
          "Hier kannst du dich für den Anlass {event-name} anmelden:<br/><br/>" \
          "{event-url}<br/><br/>" \
          "Wir freuen uns, dich wieder mit dabei zu haben."
      )
    end

    subject { mail.body }

    it "renders placeholders" do
      is_expected.to match(/Top Event/)
      is_expected.to match(/#{Regexp.escape person.salutation_value}/)
    end
  end
end
