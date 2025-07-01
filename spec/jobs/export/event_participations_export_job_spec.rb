#  Copyright (c) 2025, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.
#
require "spec_helper"

describe Export::EventParticipationsExportJob do
  let(:participation) { event_participations(:top_participant) }
  let(:user) { participation.person }
  let(:event) { participation.event }
  let(:filename) { AsyncDownloadFile.create_name("event_participation_export", user.id) }
  let(:params) { {filter: "all"} }
  let(:format) { :csv }

  subject(:job) { Export::EventParticipationsExportJob.new(format, user.id, event.id, groups(:be).id, params.merge(filename: filename)) }

  let(:file) { AsyncDownloadFile.from_filename(filename, format) }

  before do
    SeedFu.quiet = true
    SeedFu.seed [Rails.root.join("db", "seeds")]
  end

  it "exports 3 lines" do
    job.perform
    expect(file.read).to have(3).lines
  end

  describe "filtered export" do
    before { params[:nds_course] = true }

    it "exports 3 lines" do
      job.perform
      expect(file.read).to have(3).lines
    end

    context "with show details permissions" do
      let(:user) { people(:bulei) }

      it "exports only 2 lines" do
        job.perform
        expect(file.read).to have(2).lines
      end
    end
  end
end
