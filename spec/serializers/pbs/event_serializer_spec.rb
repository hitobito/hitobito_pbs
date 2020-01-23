#  Copyright (c) 2019, Pfadibewegung Schweiz This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe EventSerializer do
  let(:super_camp)     { events(:bund_supercamp) }
  let(:sub_camp)       { events(:schekka_camp) }
  let(:controller)     { double().as_null_object }

  subject { serializer.to_hash }


  context 'event' do
    let(:event) { events(:top_event) }

    it 'does not have sub_camps nor super_camp  links' do
      hash = EventSerializer.new(event.decorate, controller: controller).to_hash
      event = hash[:events].first
      expect(event[:links]).not_to have_key :sub_camps
      expect(event[:links]).not_to have_key :super_camp
    end
  end

  context 'with leader and abteilungsleitung' do
    let(:leader) { people(:al_schekka) }
    let(:abteilungsleitung) { people(:al_berchtold) }

    before do
      event.leader = leader
      event.abteilungsleitung = abteilungsleitung
      event.save
    end


    it 'includes leader' do
      hash = EventSerializer.new(event.decorate, controller: controller).to_hash
      event = hash[:events].first

      expect(event[:links]).to have_key :leader
      expect(event[:links]).to have_key :abteilungsleitung
      expect(hash[:linked]['events'].first[:id]).to eq sub_camp.id
    end
  end

  context 'sub_camps' do
    before { sub_camp.update(parent_id: super_camp.id) }

    it 'includes sub_camps via link in super_camp' do
      expect(controller).to receive(:group_event_url).with(sub_camp.groups.first, sub_camp, format: :json)

      hash = EventSerializer.new(super_camp.decorate, controller: controller).to_hash
      event = hash[:events].first
      expect(event[:links][:sub_camps]).to eq [sub_camp.id]
      expect(hash[:linked]['events'].first[:id]).to eq sub_camp.id
      expect(hash[:linked]['events'].first[:name]).to eq 'Sommerlager'
      expect(hash[:linked]['events'].first).to have_key :href
    end

    it 'includes super_camp via link in sub_camp' do
      expect(controller).to receive(:group_event_url).with(super_camp.groups.first, super_camp, format: :json)

      hash = EventSerializer.new(sub_camp.decorate, controller: controller).to_hash
      event = hash[:events].first
      expect(event[:links][:super_camp]).to eq super_camp.id
      expect(hash[:linked]['events'].first[:id]).to eq super_camp.id
      expect(hash[:linked]['events'].first[:name]).to eq 'Hauptlager'
      expect(hash[:linked]['events'].first).to have_key :href
      expect(hash[:events].first[:links][:super_camp]).to eq super_camp.id
    end
  end
end
