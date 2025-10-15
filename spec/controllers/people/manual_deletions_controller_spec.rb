# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require "spec_helper"

describe People::ManualDeletionsController do
  let(:group) { groups(:schekka) }
  let!(:person_with_expired_roles) {
    Fabricate(Group::Abteilung::Passivmitglied.name.to_sym,
      group: group,
      start_on: 11.months.ago,
      end_on: 10.months.ago).person
  }

  before { sign_in(people(:al_schekka)) }

  describe "POST #delete" do
    context "with recent event participation" do
      before do
        event = Fabricate(:event, dates: [Event::Date.new(start_at: 10.days.ago)])
        Event::Participation.create!(event: event, person: person_with_expired_roles)
      end

      it "does not delete" do
        expect do
          post :delete, params: {group_id: group.id, person_id: person_with_expired_roles.id}
        end.to raise_error(StandardError)
      end
    end

    context "with old event participation" do
      before do
        event = Fabricate(:event, dates: [Event::Date.new(start_at: 12.years.ago)])
        Event::Participation.create!(event: event, person: person_with_expired_roles)
      end

      it "deletes" do
        expect(person_with_expired_roles.minimized_at).to be_nil

        post :delete, params: {group_id: group.id, person_id: person_with_expired_roles.id}

        expect(flash[:notice]).to eq("#{person_with_expired_roles.full_name} wurde erfolgreich gelöscht.")
      end
    end
  end

  describe "POST #minimize" do
    context "with recent event participation" do
      before do
        event = Fabricate(:event, dates: [Event::Date.new(start_at: 10.days.ago)])
        Event::Participation.create!(event: event, person: person_with_expired_roles)
      end

      it "does not minimize" do
        expect do
          post :minimize, params: {group_id: group.id, person_id: person_with_expired_roles.id}
        end.to raise_error(StandardError)
      end
    end

    context "with old event participation" do
      before do
        event = Fabricate(:event, dates: [Event::Date.new(start_at: 12.years.ago)])
        Event::Participation.create!(event: event, person: person_with_expired_roles)
      end

      it "minimizes" do
        expect(person_with_expired_roles.minimized_at).to be_nil

        post :minimize, params: {group_id: group.id, person_id: person_with_expired_roles.id}

        person_with_expired_roles.reload

        expect(person_with_expired_roles.minimized_at).to be_present
        expect(flash[:notice]).to eq("#{person_with_expired_roles.full_name} wurde erfolgreich minimiert.")
      end
    end
  end
end
