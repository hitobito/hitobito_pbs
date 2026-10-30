#  Copyright (c) 2025-2026, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.
#
require "spec_helper"
require "csv"

describe Export::EventParticipationsExportJob do
  include JobObservationSpecHelper

  let(:participation) { event_participations(:top_participant) }
  let(:user) { participation.person }
  let(:event) { participation.event }
  let(:params) { {filter: "all"} }
  let(:format) { :csv }

  subject(:job) {
    Export::EventParticipationsExportJob.new(format, user.id, event.id, groups(:be).id,
      params.merge(filename: "event_participation_export"))
  }

  let(:file) { subject.job_observation }

  before do
    SeedFu.quiet = true
    SeedFu.seed [Rails.root.join("db", "seeds")]
  end

  it "exports 3 lines" do
    job.enqueue!
    job.perform

    expect(read_data_from_generated_file(file)).to have(3).lines
  end

  describe "filtered export" do
    before { params[:nds_course] = true }

    it "exports 3 lines" do
      job.enqueue!
      job.perform

      expect(read_data_from_generated_file(file)).to have(3).lines
    end

    context "with show details permissions" do
      let(:user) { people(:bulei) }

      it "exports only 2 lines" do
        job.enqueue!
        job.perform

        expect(read_data_from_generated_file(file)).to have(2).lines
      end

      it "call to data succeeds for non nds course " do
        params[:nds_course] = false
        params[:details] = true
        expect(job.data).to have(3).lines
      end
    end
  end

  describe "full export" do
    let(:user) { people(:bulei) }
    let!(:question) { Fabricate(:event_question, event: event, question: "Vegi?") }

    before { params[:details] = true }

    it "includes the event questions" do
      csv = CSV.parse(job.data.delete_prefix(Export::Csv::UTF8_BOM),
        headers: true, col_sep: Settings.csv.separator)

      expect(csv.headers).to include("Vegi?")
    end
  end

  describe "household details export" do
    before { params[:household_details] = true }

    it "exports the participants' households" do
      expect { job.data }.not_to raise_error
    end
  end
end
