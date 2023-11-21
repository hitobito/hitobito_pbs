# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe AlumniMailer do
  let(:person) { Fabricate.build(:person, email: 'person@example.com') }

  let(:ex_members_group_ids) do
    [
      # parent is Group::Abteilung
      Fabricate(Group::Ehemalige.name, name: 'Ex-Members Group 1',
                parent: groups(:schekka)).id,
      # parent is Group::Region
      Fabricate(Group::Ehemalige.name, name: 'Ex-Members Group 2',
                parent: groups(:bern)).id,
      # parent is Group::Kantonalverband
      Fabricate(Group::Ehemalige.name, name: 'Ex-Members Group 2', parent: groups(:be)).id
    ]
  end

  let(:silverscout_group_ids) do
    [
      Fabricate(Group::SilverscoutsRegion.name, name: 'Bern',
                parent: groups(:silverscouts)).id,
      Fabricate(Group::SilverscoutsRegion.name, name: 'Luzern',
                parent: groups(:silverscouts)).id
    ]
  end

  context '#invitation' do
    let(:mail) { AlumniMailer.invitation(person, ex_members_group_ids, silverscout_group_ids) }

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
      silverscout_group_ids.each do |id|
        group = Group.find(id)
        expect(body).to have_link(group.name,
                                  href: group_self_registration_url(group_id: group.id,
                                                                    target: '_blank'))
      end

      expect(body).to have_content('Ehemalige-Gruppen Selbstregistrierung:')
      ex_members_group_ids.each do |id|
        group = Group.find(id)
        expect(body).to have_link("#{group.parent.name}: #{group.name}",
                                  href: group_self_registration_url(group_id: group.id,
                                                                    target: '_blank'))
      end
    end

  end

  context '#reminder' do
    let(:mail) { AlumniMailer.reminder(person, ex_members_group_ids, silverscout_group_ids) }

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
      silverscout_group_ids.each do |id|
        group = Group.find(id)
        expect(body).to have_link(group.name,
                                  href: group_self_registration_url(group_id: group.id,
                                                                    target: '_blank'))
      end

      expect(body).to have_content('Ehemalige-Gruppen Selbstregistrierung:')
      ex_members_group_ids.each do |id|
        group = Group.find(id)
        expect(body).to have_link("#{group.parent.name}: #{group.name}",
                                  href: group_self_registration_url(group_id: group.id,
                                                                    target: '_blank'))
      end
    end
  end

end
