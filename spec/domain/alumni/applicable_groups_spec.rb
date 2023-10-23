# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Alumni::ApplicableGroups do
  let(:role) { roles(:pegasus_pfadi) }

  subject { described_class.new(role) }

  context '#silverscout_groups' do
    def make_group(name, selfreg:, **opts)
      Fabricate(
        Group::SilverscoutsRegion.name.to_sym,
        name: name,
        parent: silverscouts,
        self_registration_role_type: selfreg ? 'Group::SilverscoutsRegion::Mitglied' : nil,
        **opts
      )
    end

    let(:silverscouts) { groups(:silverscouts) }
    let(:selfreg_group) { make_group('Bern', selfreg: true) }

    it 'includes groups with self_registration_role_type set' do
      selfreg_group2 = make_group('Zürich', selfreg: true)

      expect(subject.silverscout_groups).to match_array [selfreg_group, selfreg_group2]
    end

    it 'excludes groups with blank self_registration_role_type' do
      _non_selfreg_group = make_group('Zürich', selfreg: false)

      expect(subject.silverscout_groups).to match_array [selfreg_group]
    end

    it 'excludes deleted groups' do
      _deleted_group = make_group('Zürich', selfreg: true, deleted_at: 1.day.ago)

      expect(subject.silverscout_groups).to match_array [selfreg_group]
    end

    it 'excludes groups of other types' do
      _other_type_group = Fabricate(
        Group::Ehemalige.name.to_sym,
        name: 'Zürich',
        parent: groups(:berchtold),
        self_registration_role_type: 'Group::SilverscoutsRegion::Mitglied'
      )

      expect(subject.silverscout_groups).to match_array [selfreg_group]
    end
  end

  context '#ex_members_groups' do
    def make_group(parent:, selfreg:, **opts)
      Fabricate(
        Group::Ehemalige.name.to_sym,
        name: 'Ehemalige',
        parent: parent,
        self_registration_role_type: selfreg ? 'Group::Ehemalige::Mitglied' : nil,
        **opts
      )
    end

    it 'includes groups with self_registration_role_type set' do
      selfreg_group1 = make_group(parent: role.group.layer_group, selfreg: true)
      selfreg_group2 = make_group(parent: role.group.layer_group, selfreg: true)

      expect(subject.ex_members_groups).to match_array [selfreg_group1, selfreg_group2]
    end

    it 'excludes groups with blank self_registration_role_type' do
      _non_selfreg_group = make_group(parent: role.group.layer_group, selfreg: false)

      expect(subject.ex_members_groups).to be_empty
    end

    it 'exclude deleted groups' do
      _deleted_group = make_group(parent: role.group.layer_group, selfreg: true,
                                  deleted_at: 1.day.ago)

      expect(subject.ex_members_groups).to be_empty
    end

    it 'includes groups of same and upper layer' do
      schekka_group = make_group(parent: groups(:schekka), selfreg: true)
      bern_group = make_group(parent: groups(:bern), selfreg: true)
      be_group = make_group(parent: groups(:be), selfreg: true)

      expect(subject.ex_members_groups).to match_array [schekka_group, bern_group, be_group]
    end

    it 'excludes groups uncle and cousin layers' do
      _berchtold_group = make_group(parent: groups(:berchtold), selfreg: true)
      _oberland_group = make_group(parent: groups(:oberland), selfreg: true)
      _zh_group = make_group(parent: groups(:zh), selfreg: true)

      expect(subject.ex_members_groups).to be_empty
    end

    it 'excludes groups of child layers' do
      role = roles(:bulei)
      subject = described_class.new(role)

      _zh_group = make_group(parent: groups(:zh), selfreg: true)
      _be_group = make_group(parent: groups(:be), selfreg: true)
      _bern_group = make_group(parent: groups(:bern), selfreg: true)
      _patria_group = make_group(parent: groups(:patria), selfreg: true)
      _schekka_group = make_group(parent: groups(:schekka), selfreg: true)

      expect(subject.ex_members_groups).to be_empty
    end

  end

end
