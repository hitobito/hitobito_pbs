#  Copyright (c) 2012-2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe GroupMembershipMailer do
  let(:recipient) { people(:child) }
  let(:actuator) { people(:al_schekka) }
  let(:group) { groups(:schekka) }
  let(:mail) { GroupMembershipMailer.added_to_group(recipient, actuator, group) }

  context "headers" do
    subject { mail }

    its(:subject) { is_expected.to eq "Aufnahme in Gruppe" }
    its(:to) { is_expected.to eq ["child1@hitobito.example.com"] }
    its(:from) { is_expected.to eq ["noreply@localhost"] }
  end

  context "body" do
    subject { mail.body }

    it "renders placeholders" do
      is_expected.to match(/Hallo My/)
      is_expected.to match(/AL Schekka \/ Torben hat dich zur Gruppe.*Schekka.*hinzugefügt/)
    end
  end

  context "with additional emails" do
    it "does not send to them" do
      Fabricate(:additional_email, contactable: recipient)
      expect(mail.to).to eq [recipient.email]
    end
  end
end
