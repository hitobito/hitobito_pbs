#  Copyright (c) 2019 Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe SupercampsController do

  describe 'supercamps available on group and above' do
    it 'finds supercamps on group and above' do

    end
  end

  describe 'query possible supercamps' do

  end

  describe 'inherit supercamp data' do
    before do
      sign_in(people(:al_schekka))
      request.env['HTTP_REFERER'] = '/'
      post :connect, group_id: group.id, supercamp_id: supercamp.id, event: event_form_data
    end

    let!(:supercamp_dates) { event_dates(:sixth, :sixth_two) }
    let(:supercamp) { events(:bund_supercamp) }
    let(:camp) do
      events(:schekka_camp).tap do |c|
        c.update(al_visiting: true,
                 kantonalverband_rules_applied: true,
                 lagerreglement_applied: true,
                 coach_visiting: true,
                 j_s_rules_applied: true,
                 al_present: true)
      end
    end
    let(:event_form_data) { camp.attributes }
    let(:group) { camp.groups.first }
    let(:result) { flash[:event_with_merged_supercamp] }

    it 'authorizes request' do
      # TODO
    end

    it 'redirects back' do
      # TODO
    end

    it 'name is calculated' do
      expect(result[:name]).to eq(supercamp.name + ': ' + group.display_name)
    end

    it 'description is calculated' do
      expect(result[:description]).to eq((supercamp.description.to_s + "\n\n" + camp.description.to_s).strip)
    end

    it 'parent_id is correct' do
      expect(result[:parent_id]).to eq(supercamp.id.to_s)
    end

    it 'dates from supercamp' do
      attrs = %w[label location start_at finish_at]
      expect(result[:dates_attributes].map { |d| d.slice(attrs) })
        .to eq(supercamp.dates.map { |d| d.attributes.slice(attrs) })
    end

    [
      :state, :lagerreglement_applied, :kantonalverband_rules_applied, :j_s_rules_applied,
      :leader_id, :abteilungsleitung_id, :al_present, :al_visiting, :al_visiting_date, :coach_id,
      :coach_visiting, :coach_visiting_date, :advisor_mountain_security, :advisor_snow_security,
      :advisor_water_security
    ].each do |attr|
      it attr.to_s + ' from subcamp' do
        expect(result[attr]).to eq(camp.attributes[attr.to_s])
      end
    end

    [
      :motto, :cost, :location, :canton, :coordinates, :altitude, :emergency_phone, :landlord,
      :landlord_permission_obtained, :local_scout_contact_present, :local_scout_contact,
      :j_s_kind, :j_s_security_mountain, :j_s_security_snow, :j_s_security_water,
      :application_opening_at, :application_closing_at, :application_conditions, :maximum,
      :external_applications, :signature, :signature_confirmation, :signature_confirmation_text,
      :paper_application_required, :participants_can_apply, :participants_can_cancel
    ].each do |attr|
      it attr.to_s + ' from supercamp' do
        expect(result[attr]).to eq(supercamp.attributes[attr.to_s])
      end
    end

  end
end
