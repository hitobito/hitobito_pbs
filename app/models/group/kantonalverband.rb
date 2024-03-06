# encoding: utf-8

#  Copyright (c) 2012-2021, Pfadibewegung Schweiz. This file is part of
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
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  deleted_at                  :datetime
#  layer_group_id              :integer
#  creator_id                  :integer
#  updater_id                  :integer
#  deleter_id                  :integer
#  require_person_add_requests :boolean          default(FALSE), not null
#  pta                         :boolean          default(FALSE), not null
#  vkp                         :boolean          default(FALSE), not null
#  pbs_material_insurance      :boolean          default(FALSE), not null
#  website                     :string(255)
#  pbs_shortname               :string(15)
#  bank_account                :string(255)
#  description                 :text
#  application_approver_role   :string
#  gender                      :string(1)
#  try_out_day_at              :date
#

class Group::Kantonalverband < Group

  self.layer = true
  self.event_types = [Event, Event::Course, Event::Camp]

  self.used_attributes += [:cantons, :group_health]

  children Group::Region,
           Group::Abteilung,
           Group::KantonalesGremium,
           Group::InternesKantonalesGremium,
           Group::KantonaleKommission,
           Group::Ehemalige


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
    existing = kantonalverband_cantons.pluck(:id, :canton)
    existing_cantons = existing.map(&:last)

    deletions = existing.map do |id, canton|
      next if list.include?(canton)

      { id: id, _destroy: true }
    end.compact

    additions = list.map do |canton|
      next if canton.blank?
      next if existing_cantons.include?(canton)

      { canton: canton, kantonalverband: self }
    end.compact

    self.kantonalverband_cantons_attributes = deletions + additions
  end

  def kantonalverband
    self
  end

  ### ROLES

  class Adressverwaltung < ::Role
    self.permissions = [:layer_and_below_full]
    self.two_factor_authentication_enforced = true
  end
  class PowerUser < Adressverwaltung; end

  class Beisitz < ::Role
    self.permissions = [:group_read]
  end

  class Coach < ::Role
    self.permissions = [:layer_and_below_read, :contact_data]
    self.two_factor_authentication_enforced = true
  end

  class Ehrenmitglied < ::Role
    self.permissions = []
    self.kind = :passive
  end

  class Kantonsleitung < ::Role
    self.permissions = [:layer_and_below_full, :contact_data, :approve_applications]
    self.two_factor_authentication_enforced = true
  end

  class Kassier < ::Role
    self.permissions = [:layer_and_below_read, :contact_data]
    self.two_factor_authentication_enforced = true
  end

  class Rechnungen < ::Role
    self.permissions = [:layer_and_below_read, :finance, :contact_data]
    self.two_factor_authentication_enforced = true
  end

  class Leitungskursbetreuung < ::Role
    self.permissions = [:layer_and_below_read, :contact_data]
    self.two_factor_authentication_enforced = true
  end

  class Mediensprecher < ::Role
    self.permissions = [:layer_and_below_read, :contact_data]
    self.two_factor_authentication_enforced = true
  end

  class Mitarbeiter < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class MitgliedKrisenteam < ::Role
    self.permissions = [:layer_and_below_read, :contact_data, :crisis_trigger]
    self.two_factor_authentication_enforced = true
  end

  class Krisenverantworlicher < ::Role
    self.permissions = [:group_read, :crisis_trigger]
  end

  class Passivmitglied < ::Role
    self.permissions = []
    self.kind = :passive
  end

  class Selbstregistriert < ::Role
    self.permissions = []
    self.basic_permissions_only = true
  end

  class Praesidium < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class PraesidiumApv < ::Role
    self.permissions = [:group_read]
  end

  class Redaktor < ::Role
    self.permissions = [:layer_and_below_read, :contact_data]
    self.two_factor_authentication_enforced = true
  end

  class Revisor < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Sekretariat < ::Role
    self.permissions = [:layer_and_below_full, :contact_data]
    self.two_factor_authentication_enforced = true
  end

  class Spezialfunktion < ::Role
    self.permissions = [:group_read]
  end

  class Uebersetzer < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungAbteilungen < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungAnimationSpirituelle < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungAusbildung < ::Role
    self.permissions = [:layer_full, :layer_and_below_read, :contact_data, :approve_applications]
    self.two_factor_authentication_enforced = true
  end

  class VerantwortungBetreuung < ::Role
    self.permissions = [:layer_and_below_read, :contact_data]
    self.two_factor_authentication_enforced = true
  end

  class VerantwortungBiberstufe < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungIntegration < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungInternationales < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungSuchtpraeventionsprogramm < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungKantonsarchiv < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungKrisenteam < ::Role
    self.permissions = [:layer_and_below_read, :contact_data, :crisis_trigger]
    self.two_factor_authentication_enforced = true
  end

  class VerantwortungEhrenamt < ::Role
    self.permissions = [:layer_and_below_read, :contact_data]
    self.two_factor_authentication_enforced = true
  end

  class VerantwortungLagermeldung < ::Role
    self.permissions = [:layer_and_below_read, :contact_data]
    self.two_factor_authentication_enforced = true
  end

  class VerantwortungLagerplaetze < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungMaterialverkaufsstelle < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungPfadiTrotzAllem < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungPfadistufe < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungPiostufe < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungPr < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungPraeventionSexuellerAusbeutung < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungProgramm < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungRoverstufe < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungWolfstufe < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VizePraesidium < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Webmaster < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungNachhaltigkeit < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  roles Kantonsleitung,
        Sekretariat,
        Adressverwaltung,
        PowerUser,
        Praesidium,
        VizePraesidium,
        PraesidiumApv,
        Mitarbeiter,
        Beisitz,

        Kassier,
        Rechnungen,
        Revisor,
        Redaktor,
        Webmaster,
        Mediensprecher,
        Uebersetzer,
        MitgliedKrisenteam,

        Coach,
        Leitungskursbetreuung,

        VerantwortungBiberstufe,
        VerantwortungWolfstufe,
        VerantwortungPfadistufe,
        VerantwortungPiostufe,
        VerantwortungRoverstufe,
        VerantwortungPfadiTrotzAllem,
        VerantwortungAbteilungen,
        VerantwortungAnimationSpirituelle,
        VerantwortungAusbildung,
        VerantwortungBetreuung,
        VerantwortungIntegration,
        VerantwortungInternationales,
        VerantwortungSuchtpraeventionsprogramm,
        VerantwortungKantonsarchiv,
        VerantwortungKrisenteam,
        VerantwortungEhrenamt,
        VerantwortungLagermeldung,
        VerantwortungLagerplaetze,
        VerantwortungMaterialverkaufsstelle,
        VerantwortungPr,
        VerantwortungPraeventionSexuellerAusbeutung,
        VerantwortungProgramm,
        VerantwortungNachhaltigkeit,

        Spezialfunktion,

        Ehrenmitglied,
        Passivmitglied,
        Selbstregistriert
end
