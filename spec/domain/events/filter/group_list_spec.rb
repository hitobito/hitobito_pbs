#  Copyright (c) 2012-2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe Events::Filter::GroupList do
  let(:be) { groups(:be) }
  let(:camp) { events(:schekka_camp) }
  let(:user) { people(:rl_bern) }
  let(:range) { "all" }
  let(:default_params) do
    {year: 2012, type: "Event::Camp", range: range}
  end

  subject { described_class.new(be, user, "Event::Camp", filter, 2012, nil).scope }

  def list_entries(params = {})
    described_class.new(group, user, default_params.merge(params)).entries
  end

  before do
    KantonalverbandCanton.create!(kantonalverband: be, canton: "be")
    expect(be.reload.cantons).to eq ["be"]
  end

  context "filter all" do
    context "be" do
      let(:group) { be }

      it "lists camp" do
        expect(list_entries).to eq [camp]
      end
    end
  end

  context "filter canton" do
    let(:range) { "canton" }

    context "be" do
      let(:group) { be }

      it "does not list camp" do
        expect(list_entries).to eq []
      end

      context "camp is assigned to be" do
        before { camp.update(canton: "be") }

        it "lists camp" do
          expect(list_entries).to eq [camp]
        end

        it "does not list camp if assigned to different kantonalverband" do
          camp.update(groups: [groups(:zh)])
          expect(list_entries).to eq []
        end

        context "as krisenteam member" do
          let(:user) { people(:be_crisis_member) }

          it "does list camp if assigned to different kantonalverband" do
            camp.update(groups: [groups(:zh)])
            puts list_entries.niceql
            expect(list_entries).to eq [camp]
          end
        end
      end
    end
  end
end
