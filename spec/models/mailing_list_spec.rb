#  Copyright (c) 2022, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe MailingList do
  subject { mailing_lists(:sunnewirbu) }

  before { is_expected.to be_valid }

  context "mail_name" do
    context "layer has pbs_shortname" do
      before do
        subject.group.layer_group.update!(pbs_shortname: "PBS00")
      end

      it "accepts empty value" do
        subject.mail_name = nil
        is_expected.to be_valid

        subject.mail_name = ""
        is_expected.to be_valid
      end

      it "accepts mail_name with suffix" do
        subject.mail_name = "something.pbs00"
        is_expected.to be_valid
      end

      it "does not accept mail_name without suffix" do
        subject.mail_name = "something"
        is_expected.not_to be_valid

        subject.mail_name = "somethingpbs00"
        is_expected.not_to be_valid
      end

      it "allows to keep old mail_name even if invalid" do
        subject.mail_name = "invalid"
        subject.save(validate: false)

        subject.name = "Some change"
        is_expected.to be_valid
      end
    end

    context "layer has no pbs_shortname" do
      before do
        subject.group.layer_group.update!(pbs_shortname: nil)
      end

      it "accepts empty value" do
        subject.mail_name = nil
        is_expected.to be_valid

        subject.mail_name = ""
        is_expected.to be_valid
      end

      it "accepts mail_name with suffix" do
        subject.mail_name = "something.pbs00"
        is_expected.to be_valid
      end

      it "accepts mail_name without suffix" do
        subject.mail_name = "something"
        is_expected.to be_valid

        subject.mail_name = "somethingpbs00"
        is_expected.to be_valid
      end
    end
  end
end
