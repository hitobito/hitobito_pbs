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
class MemberCount < ActiveRecord::Base

  COUNT_CATEGORIES = [:leiter, :biber, :woelfe, :pfadis, :pios, :rover, :pta]
  COUNT_COLUMNS = COUNT_CATEGORIES.collect { |c| [:"#{c}_f", :"#{c}_m"] }.flatten

  attr_accessible *COUNT_COLUMNS

  belongs_to :abteilung, class_name: 'Group::Abteilung'
  belongs_to :region, class_name: 'Group::Region'
  belongs_to :kantonalverband, class_name: 'Group::Kantonalverband'

  validates :year, uniqueness: { scope: :abteilung_id }
  validates *COUNT_COLUMNS,
            numericality: { greater_than_or_equal_to: 0, allow_nil: true }


  def total
    f + m
  end

  def f
    sum_columns(COUNT_CATEGORIES, 'f')
  end

  def m
    sum_columns(COUNT_CATEGORIES, 'm')
  end

  COUNT_CATEGORIES.each do |c|
    define_method c do
      send("#{c}_f").to_i + send("#{c}_m").to_i
    end
  end

  private

  def sum_columns(columns, gender)
    columns.inject(0) do |sum, c|
      sum + send("#{c}_#{gender}").to_i
    end
  end

  class << self

    def total_by_kantonalverbaende(year)
      totals_by(year, :kantonalverband_id)
    end

    def total_by_abteilungen(year, state)
      totals_by(year, :abteilung_id, kantonalverband_id: state.id)
    end

    def total_for_bund(year)
      totals_by(year, :year).first
    end

    def total_for_abteilung(year, abteilung)
      totals_by(year, :abteilung_id, abteilung_id: abteilung.id).first
    end

    def totals(year)
      columns = 'kantonalverband_id, ' +
                'region_id, ' +
                'abteilung_id, ' +
                COUNT_COLUMNS.collect {|c| "SUM(#{c}) AS #{c}" }.join(',')

      select(columns).where(year: year)
    end

    private

    def totals_by(year, group_by, conditions = {})
      totals(year).where(conditions).group(group_by)
    end

  end

end
