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

class Group::Bund < Group

  self.layer = true
  self.event_types = [Event, Event::Course, Event::Camp]

  children Group::Kantonalverband,
           Group::Diözesanvorstand,
           Group::AG,
		   Group::Büro

  ### INSTANCE METHODS

  def census_total(year)
    MemberCount.total_for_bund(year)
  end

  def census_groups(year)
    MemberCount.total_by_kantonalverbaende(year)
  end

  def census_details(year)
    MemberCount.details_for_bund(year)
  end

  def member_counts
    MemberCount.all
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

  class ItSupport < ::Role
    self.permissions = [:layer_and_below_full, :contact_data, :admin, :impersonation]
  end

  class Passivmitglied < ::Role
    self.permissions = []
    self.kind = :passive
  end

  

  roles ItSupport,
        Ehrenmitglied,
        Passivmitglied,
        Kontaktperson

end
