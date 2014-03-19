# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# == Schema Information
#
# Table name: groups
#
#  id                     :integer          not null, primary key
#  parent_id              :integer
#  lft                    :integer
#  rgt                    :integer
#  name                   :string(255)      not null
#  short_name             :string(31)
#  type                   :string(255)      not null
#  email                  :string(255)
#  address                :string(1024)
#  zip_code               :integer
#  town                   :string(255)
#  country                :string(255)
#  contact_id             :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  deleted_at             :datetime
#  layer_group_id         :integer
#  creator_id             :integer
#  updater_id             :integer
#  deleter_id             :integer
#  pta                    :boolean          default(FALSE), not null
#  vkp                    :boolean          default(FALSE), not null
#  pbs_material_insurance :boolean          default(FALSE), not null
#  website                :string(255)
#  pbs_shortname          :string(15)
#  bank_account           :string(255)
#  description            :text
#
class Group::Abteilung < Group

  self.layer = true

  self.used_attributes += [:pta, :vkp, :pbs_material_insurance]
  self.superior_attributes += [:pta, :vkp, :pbs_material_insurance]

  children Group::Biber,
           Group::Woelfe,
           Group::Pfadi,
           Group::Pio,
           Group::AbteilungsRover,
           Group::Pta,
           Group::Elternrat,
           Group::AbteilungsGremium

  has_many :member_counts

  ### INSTANCE METHODS

  def kantonalverband
    ancestors.where(type: Group::Kantonalverband.sti_name).first
  end

  def region
    ancestors.where(type: Group::Region.sti_name).order('lft DESC').first
  end

  def census_groups(year)
    []
  end

  def census_total(year)
    MemberCount.total_for_abteilung(year, self)
  end

  def census_details(year)
    MemberCount.details_for_abteilung(year, self)
  end

  def population_approveable?
    current_census = Census.current
    current_census && !MemberCounter.new(current_census.year, self).exists?
  end


  ### ROLES

  class Abteilungsleitung < ::Role
    self.permissions = [:layer_full, :contact_data]
  end

  class AbteilungsleitungStv < ::Role
    self.permissions = [:layer_full, :contact_data]
  end

  class Adressverwaltung < ::Role
    self.permissions = [:layer_full]
  end

  class Beisitz < ::Role
    self.permissions = [:group_read]
  end

  class Coach < ::Role
    self.permissions = [:layer_read, :contact_data]
  end

  class Ehrenmitglied < ::Role
    self.permissions = []
    self.kind = :passive
  end

  class Heimverwaltung < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Kassier < ::Role
    self.permissions = [:layer_read, :contact_data]
  end

  class Materialwart < ::Role
    self.permissions = [:group_read]
  end

  class Passivmitglied < ::Role
    self.permissions = []
    self.kind = :passive
  end

  class Praeses < ::Role
    self.permissions = [:group_read]
  end

  class Praesidium < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class PraesidiumApv < ::Role
    self.permissions = [:group_read]
  end

  class Redaktor < ::Role
    self.permissions = [:layer_read, :contact_data]
  end

  class Revisor < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Sekretariat < ::Role
    self.permissions = [:layer_full, :contact_data]
  end

  class Spezialfunktion < ::Role
    self.permissions = [:group_read]
  end

  class StufenleitungBiber < ::Role
    self.permissions = [:layer_read]
  end

  class StufenleitungWoelfe < ::Role
    self.permissions = [:layer_read]
  end

  class StufenleitungPfadi < ::Role
    self.permissions = [:layer_read]
  end

  class StufenleitungPio < ::Role
    self.permissions = [:layer_read]
  end

  class StufenleitungRover < ::Role
    self.permissions = [:layer_read]
  end

  class StufenleitungPta < ::Role
    self.permissions = [:layer_read]
  end

  class VerantwortungMaterialverkaufsstelle < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungPfadiTrotzAllem < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungPr < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VizePraesidium < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Webmaster < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  roles Abteilungsleitung,
        AbteilungsleitungStv,
        Sekretariat,
        Adressverwaltung,
        Praesidium,
        VizePraesidium,
        PraesidiumApv,
        Praeses,
        Beisitz,

        StufenleitungBiber,
        StufenleitungWoelfe,
        StufenleitungPfadi,
        StufenleitungPio,
        StufenleitungRover,
        StufenleitungPta,

        Kassier,
        Revisor,
        Redaktor,
        Webmaster,
        Coach,

        VerantwortungMaterialverkaufsstelle,
        VerantwortungPfadiTrotzAllem,
        VerantwortungPr,

        Spezialfunktion,

        Ehrenmitglied,
        Passivmitglied
end
