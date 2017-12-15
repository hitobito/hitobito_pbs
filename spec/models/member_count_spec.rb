# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# == Schema Information
#
# Table name: member_counts
#
#  id                 :integer          not null, primary key
#  kantonalverband_id :integer          not null
#  region_id          :integer
#  abteilung_id       :integer          not null
#  year               :integer          not null
#  leiter_f           :integer
#  leiter_m           :integer
#  woelfe_f           :integer
#  woelfe_m           :integer
#  pfadis_f           :integer
#  pfadis_m           :integer
#  pios_f             :integer
#  pios_m             :integer
#  rover_f            :integer
#  rover_m            :integer
#  biber_f            :integer
#  biber_m            :integer
#  pta_f              :integer
#  pta_m              :integer
#


#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito_jubla and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_jubla.

require 'spec_helper'

describe MemberCount do

  let(:be)   { groups(:be) }
  let(:zh)   { groups(:zh) }
  let(:schekka)   { groups(:schekka) }
  let(:berchtold) { groups(:berchtold) }
  let(:chaeib)    { groups(:chaeib) }

  describe '.total_by_abteilungen' do

    subject { MemberCount.total_by_regionen(2012, be).to_a }

    it 'counts totals' do
      is_expected.to have(2).items

      schekka_count = subject.detect { |c| c.abteilung_id == schekka.id }
      assert_member_counts(schekka_count, 2, 3, 4, 3)

      berchtold_count = subject.detect { |c| c.abteilung_id == berchtold.id }
      assert_member_counts(berchtold_count, 1, 2, 1, 3)
    end
  end

  describe '.total_for_abteilungen' do
    subject { MemberCount.total_for_abteilung(2012, schekka) }

    it 'counts totals' do
      assert_member_counts(subject, 2, 3, 4, 3)
    end
  end

  describe '.total_for_bund' do
    subject { MemberCount.total_for_bund(2012) }

    it 'counts totals' do
      assert_member_counts(subject, 4, 7, 9, 8)
    end
  end

  describe '.total_by_kantonalverbands' do

    subject { MemberCount.total_by_kantonalverbaende(2012).to_a }

    it 'counts totals' do
      is_expected.to have(2).items

      be_count = subject.detect { |c| c.kantonalverband_id == be.id }
      assert_member_counts(be_count, 3, 5, 5, 6)

      zh_count = subject.detect { |c| c.kantonalverband_id == zh.id }
      assert_member_counts(zh_count, 1, 2, 4, 2)
    end
  end

  def assert_member_counts(count, leiter_f, leiter_m, pfadis_f, pfadis_m)
    expect(count.leiter_f).to eq(leiter_f)
    expect(count.leiter_m).to eq(leiter_m)
    expect(count.pfadis_f).to eq(pfadis_f)
    expect(count.pfadis_m).to eq(pfadis_m)
  end

end
