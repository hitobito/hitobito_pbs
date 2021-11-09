# frozen_string_literal: true

require 'spec_helper'
migration_file_name = Dir[Rails.root.join('../hitobito_pbs/db/migrate/20211109094956_prolong_j_s_qualifications_2021.rb')].first
require migration_file_name


describe ProlongJSQualifications2021 do

  before(:all) { self.use_transactional_tests = false }
  after(:all)  { self.use_transactional_tests = true }

  let(:migration) { described_class.new.tap { |m| m.verbose = false } }

  let!(:ek_qk_js) do
    qk = QualificationKind.create!(label: 'J+S Leiter LS/T Kindersport')
    Event::KindQualificationKind.create!(qualification_kind: qk,
                                         event_kind: event_kinds(:lpk),
                                         category: 'qualification',
                                         role: 'participant')
  end
  let!(:event_kind_js) { Event::Kind.create!(label: 'JS', event_kind_qualification_kinds: [ek_qk_js]) }
  # let!(:qk_js_2) { create_qualification_kind('J+S Leiter LS/T Jugendsport') }

  let!(:js_course_2021) { Fabricate(:course, kind: event_kind_js, dates: event_dates(2021)) }
  let!(:js_course_2019) { Fabricate(:course, kind: event_kind_js, dates: event_dates(2019)) }

  context '#up' do

    it 'prolongs all js qualifications completed in 2019' do
      require 'pry'; binding.pry unless $pstop
      #migration.up
    end
  end

  private

  def event_dates(year)
    start_at = Date.new(year, 06, 11)
    [Fabricate(:event_date, start_at: start_at, finish_at: start_at + 8.days)]
  end

end
