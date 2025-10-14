#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe Ability do
  let(:user) { role.person }
  let(:group) { role.group }
  let(:abteilung) { groups(:schekka) }

  subject { Ability.new(user.reload) }

  describe "Bund Mitarbeiter GS" do
    let(:role) { Fabricate(Group::Bund::MitarbeiterGs.name.to_sym, group: groups(:bund)) }

    it "may update member counts" do
      is_expected.to be_able_to(:update_member_counts, abteilung)
    end

    it "may create member counts" do
      is_expected.to be_able_to(:create_member_counts, abteilung)
    end

    it "may delete member counts" do
      is_expected.to be_able_to(:delete_member_counts, abteilung)
    end

    it "may show population" do
      is_expected.to be_able_to(:show_population, abteilung)
    end

    it "may view census for abteilung" do
      is_expected.to be_able_to(:evaluate_census, abteilung)
    end

    it "may view census for kantonalverband" do
      is_expected.to be_able_to(:evaluate_census, abteilung.kantonalverband)
    end

    it "may view census for bund" do
      is_expected.to be_able_to(:evaluate_census, group)
    end

    it "may remind census for kantonalverband" do
      is_expected.to be_able_to(:remind_census, abteilung.kantonalverband)
    end

    it "may create Census" do
      is_expected.to be_able_to(:create, Census.new)
    end
  end

  describe "Kantonsleitung" do
    let(:role) { Fabricate(Group::Kantonalverband::Kantonsleitung.name.to_sym, group: groups(:be)) }

    it "may update member counts" do
      is_expected.to be_able_to(:update_member_counts, abteilung)
    end

    it "may create member counts" do
      is_expected.to be_able_to(:create_member_counts, abteilung)
    end

    it "may delete member counts" do
      is_expected.to be_able_to(:delete_member_counts, abteilung)
    end

    it "may show population" do
      is_expected.to be_able_to(:show_population, abteilung)
    end

    it "may view census for abteilung" do
      is_expected.to be_able_to(:evaluate_census, abteilung)
    end

    it "may view census for kantonalverband" do
      is_expected.to be_able_to(:evaluate_census, abteilung.kantonalverband)
    end

    it "may view census for bund" do
      is_expected.to be_able_to(:evaluate_census, groups(:bund))
    end

    it "may remind census for kantonalverband" do
      is_expected.to be_able_to(:remind_census, abteilung.kantonalverband)
    end

    it "may not create Census" do
      is_expected.not_to be_able_to(:create, Census.new)
    end

    context "for other kantonalverband" do
      let(:role) {
        Fabricate(Group::Kantonalverband::Kantonsleitung.name.to_sym, group: groups(:zh))
      }

      it "may not update member counts" do
        is_expected.not_to be_able_to(:update_member_counts, abteilung)
      end

      it "may not delete member counts" do
        is_expected.not_to be_able_to(:delete_member_counts, abteilung)
      end

      it "may not show population" do
        is_expected.not_to be_able_to(:show_population, abteilung)
      end

      it "may view census for abteilung" do
        is_expected.to be_able_to(:evaluate_census, abteilung)
      end

      it "may not remind census" do
        is_expected.not_to be_able_to(:remind_census, abteilung.kantonalverband)
      end
    end
  end

  describe "Abteilungsleitung" do
    let(:role) {
      Fabricate(Group::Abteilung::Abteilungsleitung.name.to_sym, group: groups(:schekka))
    }

    it "may not update member counts" do
      is_expected.not_to be_able_to(:update_member_counts, abteilung)
    end

    it "may not delete member counts" do
      is_expected.not_to be_able_to(:delete_member_counts, abteilung)
    end

    it "may create member counts" do
      is_expected.to be_able_to(:create_member_counts, abteilung)
    end

    it "may show population" do
      is_expected.to be_able_to(:show_population, abteilung)
    end

    it "may view census for abteilung" do
      is_expected.to be_able_to(:evaluate_census, abteilung)
    end

    it "may view census for kantonalverband" do
      is_expected.to be_able_to(:evaluate_census, abteilung.kantonalverband)
    end

    it "may view census for bund" do
      is_expected.to be_able_to(:evaluate_census, groups(:bund))
    end

    it "may not remind census for kantonalverband" do
      is_expected.not_to be_able_to(:remind_census, abteilung.kantonalverband)
    end

    it "may not create Census" do
      is_expected.not_to be_able_to(:create, Census.new)
    end
  end
end
