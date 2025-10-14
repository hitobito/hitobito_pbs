#  Copyright (c) 2012-2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe CrisisMailer do
  include ActiveSupport::Testing::TimeHelpers

  let(:crisis) { crises(:schekka) }
  let(:date) { "2019-05-08 09:57:00 UTC+2" }
  let(:link) { %(<a href="http://test.host/groups/#{crisis.group.id}">#{crisis.group}</a>) }

  before do
    @leiter = Fabricate(Group::Bund::LeitungKernaufgabeKommunikation.name.to_sym,
      group: groups(:bund)).person
    @verantwortlich = Fabricate(Group::Bund::VerantwortungKrisenteam.name.to_sym,
      group: groups(:bund)).person
    @kanton_verantwortlich = Fabricate(Group::Kantonalverband::VerantwortungKrisenteam.name.to_sym,
      group: groups(:be)).person
  end

  context "triggered" do
    let(:mail) { CrisisMailer.triggered(crisis) }

    context "headers" do
      subject { mail }

      its(:subject) { is_expected.to eq "Krise wurde eingeleitet" }
      its(:from) { is_expected.to eq ["noreply@localhost"] }
    end

    context "recipients" do
      subject { mail.to }

      it "notifies bund when created by kanton" do
        crisis.update(creator: @kanton_verantwortlich)
        expect(subject).to match_array [@leiter.email, @verantwortlich.email]
      end

      it "notifies bund and kanton when created by bund" do
        mitglied = Fabricate(Group::Bund::MitgliedKrisenteam.name.to_sym,
          group: groups(:bund)).person

        [mitglied, @leiter, @verantwortlich].each do |creator|
          crisis.update(creator: creator)
          expect(subject).to match_array [@leiter.email, @verantwortlich.email,
            @kanton_verantwortlich.email]
        end
      end
    end

    context "body" do
      subject { mail.body }

      it "renders placeholders" do
        @leiter.roles.first.update!(start_on: Time.zone.parse(date) - 1.day)

        travel_to date do
          is_expected.to match(/Alan Helpful hat am 08.05.2019 09:57/)
          is_expected.to match(/eine Krise in der Gruppe #{link} eingeleitet/)
        end
      end
    end
  end

  context "acknowledged" do
    let(:person) { people(:bulei) }
    let(:mail) { CrisisMailer.acknowledged(crisis, person) }

    before { crisis.update(acknowledged: true) }

    context "headers" do
      subject { mail }

      its(:subject) { is_expected.to eq "Krise wurde quittiert" }
      its(:to) {
        is_expected.to match_array [@leiter.email, @verantwortlich.email,
          @kanton_verantwortlich.email]
      }
      its(:from) { is_expected.to eq ["noreply@localhost"] }
    end

    context "body" do
      subject { mail.body }

      it "renders placeholders" do
        @leiter.roles.first.update!(start_on: Time.zone.parse(date) - 1.day)

        travel_to date do
          is_expected.to match(/Die von Alan Helpful am 08.05.2019 09:57/)
          is_expected.to match(/in der Gruppe #{link} eingeleitet Krise/)
          is_expected.to match(/wurde von Dr. Bundes Leiter quittiert/)
        end
      end
    end
  end
end
