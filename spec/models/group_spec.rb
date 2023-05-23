# encoding: utf-8

#  Copyright (c) 2012-2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# == Schema Information
#
# Table name: groups
#
#  id                          :integer          not null, primary key
#  parent_id                   :integer
#  lft                         :integer
#  rgt                         :integer
#  name                        :string(255)      not null
#  short_name                  :string(31)
#  type                        :string(255)      not null
#  email                       :string(255)
#  address                     :string(1024)
#  zip_code                    :integer
#  town                        :string(255)
#  country                     :string(255)
#  contact_id                  :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  deleted_at                  :datetime
#  layer_group_id              :integer
#  creator_id                  :integer
#  updater_id                  :integer
#  deleter_id                  :integer
#  require_person_add_requests :boolean          default(FALSE), not null
#  pta                         :boolean          default(FALSE), not null
#  vkp                         :boolean          default(FALSE), not null
#  pbs_material_insurance      :boolean          default(FALSE), not null
#  website                     :string(255)
#  pbs_shortname               :string(15)
#  bank_account                :string(255)
#  description                 :text
#  application_approver_role   :string
#  gender                      :string(1)
#  try_out_day_at              :date
#
require 'spec_helper'

describe Group do

  include_examples 'group types'

  describe '#all_types' do
    subject { Group.all_types }

    it 'must have silverscouts as last item' do
      expect(subject.last).to eq(Group::Silverscouts)
    end

    it 'is in hierarchical order' do
      expect(subject.collect(&:name)).to eq(
        [Group::Root,
         Group::Bund,
         Group::Kantonalverband,
         Group::Region,
         Group::RegionaleRover,
         Group::RegionalesGremium,
         Group::InternesRegionalesGremium,
         Group::RegionaleKommission,
         Group::Abteilung,
         Group::Biber,
         Group::Woelfe,
         Group::Pfadi,
         Group::Pio,
         Group::AbteilungsRover,
         Group::Pta,
         Group::Elternrat,
         Group::AbteilungsGremium,
         Group::InternesAbteilungsGremium,
         Group::KantonalesGremium,
         Group::InternesKantonalesGremium,
         Group::KantonaleKommission,
         Group::Ausbildungskommission,
         Group::BundesGremium,
         Group::BundesKommission,
         Group::Silverscouts].collect(&:name))
    end
  end

  describe Group::Kantonalverband do
    let(:group) { groups(:be) }

    context 'cantons' do
      it 'returns all assigned cantons in order' do
        group.update!(cantons: %w(ge zh be))
        expect(group.reload.cantons).to eq %w(be ge zh)
      end

      it 'removes cantons by assigning an empty list' do
        expect { group.update!(cantons: %w(ge zh be)) }.to change { KantonalverbandCanton.count }.by(3)
        expect { group.update!(cantons:[]) }.to change { KantonalverbandCanton.count }.by(-3)
        expect(group.reload.cantons).to eq []
      end
    end
  end

  describe Group::Abteilung do
    let(:group) { groups(:patria) }

    context 'group finder fields' do
      it 'returns assigned geolocations' do
        g = Fabricate(Geolocation.name.downcase.to_sym, geolocatable: group)
        expect(group.reload.geolocations).to eq [g]
      end

      it 'cannot have more geolocations than the fixed limit' do
        limit = Group::Abteilung::GEOLOCATION_COUNT_LIMIT
        (limit + 1).times { Fabricate(Geolocation.name.downcase.to_sym, geolocatable: group) }
        expect(group.reload).to have(1).error_on(:geolocations)
        expect(group.errors.full_messages.to_sentence).to match(/Treffpunkte dürfen nicht mehr als #{limit} sein/)
      end

      it 'cannot have geolocations outide of Switzerland' do
        Fabricate(:geolocation, lat: '47.0', long: '12.0', geolocatable: group)
        expect(group.reload).to have(1).error_on(:base)
        expect(group.errors.full_messages.to_sentence).to match(/Diese Koordinaten liegen nicht in der Schweiz./)
      end

      it 'can have group finder fields' do
        group.update!(gender: 'm', try_out_day_at: '2019-03-23')
        expect(group.reload.gender).to eq 'm'
        expect(group.reload.try_out_day_at).to eq Date.parse('2019-03-23')
      end
    end
  end
end
