#  Copyright (c) 2026, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe FilterNavigation::Events do
  include LayoutHelper
  include UtilityHelper
  include I18nHelper

  let(:user) { people(:bulei) }
  let(:params) do
    ActionController::Parameters.new(controller: "events", action: "index", group_id: group.id, type: "Event")
  end
  let(:filter) { Events::Filter::GroupList.new(group, user, params) }

  subject { FilterNavigation::Events.new(self, group, filter) }

  context "top layer" do
    let(:group) { groups(:bund).decorate }

    it "contains regular items" do
      expect(subject.main_items).to have(2).items
      expect(subject.active_label).to eq("Alle")
      expect(subject.main_items.first).to include("Alle")
      expect(subject.main_items.second).to include("nur Pfadibewegung Schweiz")
      expect(subject.dropdown.active).to be_falsey
      expect(subject.dropdown.label).to eq("Weitere Ansichten")
      expect(subject.dropdown.items).to have(1).items
    end
  end

  context "canton layer" do
    let(:group) { groups(:be).decorate }

    context "regular events" do
      it "contains regular items" do
        expect(subject.main_items).to have(2).items
        expect(subject.active_label).to eq("Alle")
        expect(subject.main_items.first).to include("Alle")
        expect(subject.main_items.second).to include("nur Bern")
        expect(subject.dropdown.items).to have(1).items
      end
    end

    context "camps" do
      let(:params) do
        ActionController::Parameters.new(controller: "events", action: "index", group_id: group.id, type: "Event::Camp")
      end

      it "contains camp item" do
        expect(subject.main_items).to have(3).items
        expect(subject.active_label).to eq("Alle")
        expect(subject.main_items.first).to include("Alle")
        expect(subject.main_items.second).to include("nur Bern")
        expect(subject.main_items.third).to include("durchgeführt im Kanton")
        expect(subject.dropdown.items).to have(1).items
      end
    end
  end
end
