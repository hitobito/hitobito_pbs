# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Person::LoginMailer do

  before do
    SeedFu.quiet = true
    SeedFu.seed [Rails.root.join('db', 'seeds')]
  end

  let(:sender) { people(:bulei) }
  let(:recipient) { people(:al_schekka) }
  let(:mail) { Person::LoginMailer.login(recipient, sender, 'abcdef') }


  before :all do
    template = CustomContent.find_or_create_by key: described_class::CONTENT_LOGIN
    template.update!(
      label: 'Login senden',
      subject: "Willkommen bei #{Settings.application.name}",
      body: "{recipient-name-with-salutation}<br/><br/>" \
        "Willkommen bei #{Settings.application.name}! Unter dem folgenden Link kannst du " \
        "dein Login Passwort setzen:<br/><br/>{login-url}<br/><br/>" \
        "Bis bald!<br/><br/>{sender-name}"
    )
  end

  subject { mail }

  its(:to)       { should == [recipient.email] }
  its(:reply_to) { should == [sender.email] }
  its(:subject)  { should == "Willkommen bei #{Settings.application.name}" }
  its(:body)     { should =~ /Liebe\(r\) Torben<br\/>.*test.host\/users\/password\/edit\?reset_password_token=/ }

end
