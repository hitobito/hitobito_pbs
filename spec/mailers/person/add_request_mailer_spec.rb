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

    subject { mail }

    its(:body) { should =~ /Liebe\(r\) Torben/ }

  end

  context 'ask responsibles to add person' do

    let(:leader) { people(:al_schekka) }
    let(:leader2) { people(:al_berchtold) }

    let(:person_layer) { groups(:schekka) }
    let(:responsibles) { [leader, leader2] }

    let(:mail) { Person::AddRequestMailer.ask_responsibles(request, responsibles) }

    subject { mail }

    its(:body) do
      should =~ /#{Regexp.escape(leader.salutation_value)}, #{Regexp.escape(leader2.salutation_value)}/
    end

  end

  context 'request approved' do

    context 'by leader' do
      let(:leader) { people(:al_berchtold) }
      let(:mail) { Person::AddRequestMailer.approved(person, group, requester, leader) }

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

    subject { mail }

    its(:body) { should =~ /#{Regexp.escape(requester.salutation_value)}/ }
  end

end
