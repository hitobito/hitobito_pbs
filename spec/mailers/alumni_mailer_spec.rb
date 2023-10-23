# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe AlumniMailer do
  let(:person) { Fabricate.build(:person, email: 'person@example.com') }

  let(:ex_members_groups) do
    [
      # parent is Group::Abteilung
      Fabricate.build(Group::Ehemalige.name, id: 1, name: 'Ex-Members Group 1',
                                             parent: groups(:schekka)),
      # parent is Group::Region
      Fabricate.build(Group::Ehemalige.name, id: 2, name: 'Ex-Members Group 2',
                                             parent: groups(:bern)),
      # parent is Group::Kantonalverband
      Fabricate.build(Group::Ehemalige.name, id: 3, name: 'Ex-Members Group 2', parent: groups(:be))
    ]
  end

  let(:silverscout_groups) do
    [
      Fabricate.build(Group::SilverscoutsRegion.name, id: 4, name: 'Bern',
                      parent: groups(:silverscouts)),
      Fabricate.build(Group::SilverscoutsRegion.name, id: 5, name: 'Luzern',
                      parent: groups(:silverscouts))
    ]
  end

  context '#invitation' do
    let(:mail) { AlumniMailer.invitation(person, ex_members_groups, silverscout_groups) }

    it 'renders the subject' do
      expect(mail.subject).to eq('Ehemalige Einladung zur Selbstregistrierung')
    end

    it 'renders the receiver email' do
      expect(mail.to.map(&:to_s)).to eq([person.email])
    end

    it 'renders the sender email' do
      expect(mail.header[:from].to_s).to eq Settings.email.sender
    end

    it 'renders the body' do
      body = Capybara::Node::Simple.new(mail.body.encoded)

      expect(body).to have_content('Silverscouts Selbstregistrierung:')
      silverscout_groups.each do |group|
        expect(body).to have_link(group.name,
                                  href: group_self_registration_url(group_id: group.id,
                                                                    target: '_blank'))
      end

      expect(body).to have_content('Ehemalige-Gruppen Selbstregistrierung:')
      ex_members_groups.each do |group|
        expect(body).to have_link("#{group.parent.name}: #{group.name}",
                                  href: group_self_registration_url(group_id: group.id,
                                                                    target: '_blank'))
      end
    end

  end

  context '#reminder' do
    let(:mail) { AlumniMailer.reminder(person, ex_members_groups, silverscout_groups) }

    it 'renders the subject' do
      expect(mail.subject).to eq('Ehemalige Erinnerung zur Selbstregistrierung')
    end

    it 'renders the receiver email' do
      expect(mail.to.map(&:to_s)).to eq([person.email])
    end

    it 'renders the sender email' do
      expect(mail.header[:from].to_s).to eq Settings.email.sender
    end

    it 'renders the body' do
      body = Capybara::Node::Simple.new(mail.body.encoded)

      expect(body).to have_content('Erinnerung')

      expect(body).to have_content('Silverscouts Selbstregistrierung:')
      silverscout_groups.each do |group|
        expect(body).to have_link(group.name,
                                  href: group_self_registration_url(group_id: group.id,
                                                                    target: '_blank'))
      end

      expect(body).to have_content('Ehemalige-Gruppen Selbstregistrierung:')
      ex_members_groups.each do |group|
        expect(body).to have_link("#{group.parent.name}: #{group.name}",
                                  href: group_self_registration_url(group_id: group.id,
                                                                    target: '_blank'))
      end
    end
  end

end
