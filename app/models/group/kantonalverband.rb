  
# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.
# == Schema Information
#
# Table name: groups
#
#  id                          :integer          not null, primary key
#  parent_id                   :integer
#  lft                         :integer
#  rgt                         :integer
#  name                        :string(255)      not null
#  short_name                  :string(31)
#  type                        :string(255)      not null
#  email                       :string(255)
#  address                     :string(1024)
#  zip_code                    :integer
#  town                        :string(255)
#  country                     :string(255)
#  contact_id                  :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  deleted_at                  :datetime
#  layer_group_id              :integer
#  creator_id                  :integer
#  updater_id                  :integer
#  deleter_id                  :integer
#  require_person_add_requests :boolean          default(FALSE), not null
#  pta                         :boolean          default(FALSE), not null
#  vkp                         :boolean          default(FALSE), not null
#  pbs_material_insurance      :boolean          default(FALSE), not null
#  website                     :string
#  pbs_shortname               :string(15)
#  bank_account                :string
#  description                 :text
#  application_approver_role   :string
#

class Group::Kantonalverband < Group

  self.layer = true
  self.event_types = [Event, Event::Course, Event::Camp]

  self.used_attributes += [:cantons]

  children Group::Abteilung,
           Group::Vorstand,
           Group::AG


  has_many :member_counts
  has_many :kantonalverband_cantons, -> { order(:canton) }

  accepts_nested_attributes_for :kantonalverband_cantons, allow_destroy: true


  ### INSTANCE METHODS

  def census_total(year)
    MemberCount.total_by_kantonalverbaende(year).find_by(kantonalverband_id: id)
  end

  def census_groups(year)
    MemberCount.totals_by(year, :abteilung_id, kantonalverband_id: id)
  end

  def census_details(year)
    MemberCount.details_for_kantonalverband(year, self)
  end

  def cantons
    # use collect instead of pluck to benefit from association cache
    kantonalverband_cantons.collect(&:canton)
  end

  def cantons=(list)
    self.kantonalverband_cantons_attributes =
      kantonalverband_cantons.collect { |c| { id: c.id, _destroy: true } } +
      list.select(&:present?).collect { |c| { canton: c, kantonalverband: self } }
  end

  def kantonalverband
    self
  end

  ### ROLES

   class Ehrenmitglied < ::Role
    self.permissions = []
    self.kind = :passive
  end

  class Kontaktperson < ::Role
    self.permissions = [:contact_data]
    self.kind = :external
  end

  class Passivmitglied < ::Role
    self.permissions = []
    self.kind = :passive
  end

  

  roles Ehrenmitglied,
        Passivmitglied,
        Kontaktperson
end

