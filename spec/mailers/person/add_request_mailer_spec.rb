# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Person::AddRequestMailer do

  before do
    SeedFu.quiet = true
    SeedFu.seed [Rails.root.join('db', 'seeds')]
  end

  let(:person) { people(:al_schekka) }
  let(:requester) { people(:child) }
  let(:group) { groups(:schekka) }

  let(:request) do
    Person::AddRequest::Group.create!(
      person: person,
      requester: requester,
      body: group,
      role_type: Group::Abteilung::StufenleitungBiber.sti_name)
  end

  context 'ask person to add' do

    let(:mail) { Person::AddRequestMailer.ask_person_to_add(request) }

    before :all do
      template = CustomContent.find_or_create_by key: described_class::CONTENT_ADD_REQUEST_PERSON
      template.update!(
        label: 'Anfrage Personendaten: E-Mail Freigabe durch Person',
        subject: 'Freigabe deiner Personendaten',
        body: "{recipient-name-with-salutation}<br/><br/>" \
          "{requester-name} möchte dich hier hinzufügen: <br/><br/>" \
          "{request-body}<br/><br/>" \
          "{requester-name} hat folgende schreibberechtigten Rollen: <br/><br/>" \
          "{requester-roles}<br/><br/>" \
          "Bitte bestätige oder verwerfe diese Anfrage:<br/><br/>" \
          "{answer-request-url}"
      )
    end

    subject { mail }

    its(:body) { should =~ /Liebe\(r\) Torben/ }

  end

  context 'ask responsibles to add person' do

    let(:leader) { people(:al_schekka) }
    let(:leader2) { people(:al_berchtold) }

    let(:person_layer) { groups(:schekka) }
    let(:responsibles) { [leader, leader2] }

    let(:mail) { Person::AddRequestMailer.ask_responsibles(request, responsibles) }

    before :all do
      template = CustomContent.find_or_create_by key: described_class::CONTENT_ADD_REQUEST_RESPONSIBLES
      template.update!(
        label: 'Anfrage Personendaten: E-Mail Freigabe durch Verantwortliche',
        subject: 'Freigabe Personendaten',
        body: "{recipient-names-with-salutation}<br/><br/>" \
          "{requester-name} möchte {person-name} hier hinzufügen: <br/><br/>" \
          "{request-body}<br/><br/>" \
          "{requester-name} hat folgende schreibberechtigten Rollen: <br/><br/>" \
          "{requester-roles}<br/><br/>" \
          "Bitte bestätige oder verwerfe diese Anfrage:<br/><br/>" \
          "{answer-request-url}"
      )
    end

    subject { mail }

    its(:body) do
      should =~ /#{Regexp.escape(leader.salutation_value)}, #{Regexp.escape(leader2.salutation_value)}/
    end

  end

  context 'request approved' do

    context 'by leader' do
      let(:leader) { people(:al_berchtold) }
      let(:mail) { Person::AddRequestMailer.approved(person, group, requester, leader) }

      before :all do
        template = CustomContent.find_or_create_by key: described_class::CONTENT_ADD_REQUEST_APPROVED
        template.update!(
           label: 'Anfrage Personendaten: E-Mail Freigabe akzeptiert',
           subject: 'Freigabe der Personendaten akzeptiert',
           body: "{recipient-name-with-salutation}<br/><br/>" \
             "{approver-name} hat deine Anfrage für {person-name} freigegeben.<br/><br/>" \
             "{person-name} wurde zu {request-body} hinzugefügt.<br/><br/>" \
             "{approver-name} hat folgende schreibberechtigten Rollen: <br/><br/>" \
             "{approver-roles}<br/><br/>"
        )
      end

      subject { mail }

      its(:body) { should =~ /#{Regexp.escape(requester.salutation_value)}/ }
    end

    context 'by person' do
      let(:mail) { Person::AddRequestMailer.approved(person, group, requester, person) }

      subject { mail }

      its(:body) { should =~ /#{Regexp.escape(requester.salutation_value)}/ }
    end

  end

  context 'request rejected' do
    let(:leader) { people(:al_berchtold) }
    let(:mail) { Person::AddRequestMailer.rejected(person, group, requester, leader) }

    before :all do
      template = CustomContent.find_or_create_by key: described_class::CONTENT_ADD_REQUEST_REJECTED
      template.update!(
        label: 'Anfrage Personendaten: E-Mail Freigabe abgelehnt',
        subject: 'Freigabe der Personendaten abgelehnt',
        body: "{recipient-name-with-salutation}<br/><br/>" \
          "{rejecter-name} hat deine Anfrage für {person-name} abgelehnt.<br/><br/>" \
          "{person-name} wird nicht zu {request-body} hinzugefügt.<br/><br/>" \
          "{rejecter-name} hat folgende schreibberechtigten Rollen: <br/><br/>" \
          "{rejecter-roles}<br/><br/>"
      )
    end


    subject { mail }

    its(:body) { should =~ /#{Regexp.escape(requester.salutation_value)}/ }
  end

end
