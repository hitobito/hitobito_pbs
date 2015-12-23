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
#  created_at             :datetime
#  updated_at             :datetime
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

class Group::Bund < Group

  self.layer = true
  self.event_types = [Event, Event::Course, Event::Camp]

  children Group::Kantonalverband,
           Group::BundesGremium

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

  class Adressverwaltung < ::Role
    self.permissions = [:layer_and_below_full]
  end

  class AssistenzAusbildung < ::Role
    self.permissions = [:layer_full]
  end

  class Beisitz < ::Role
    self.permissions = [:group_read]
  end

  class Coach < ::Role
    self.permissions = [:layer_and_below_read, :contact_data]
  end

  class Ehrenmitglied < ::Role
    self.permissions = []
    self.kind = :passive
  end

  class Geschaeftsleitung < ::Role
    self.permissions = [:layer_and_below_read, :contact_data, :approve_applications]
  end

  class GrossanlassCoach < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class InternationalCommissionerIcWagggs < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class InternationalCommissionerIcWosm < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Kassier < ::Role
    self.permissions = [:layer_and_below_read, :contact_data]
  end

  class Kontaktperson < ::Role
    self.permissions = [:contact_data]
    self.kind = :external
  end

  class Leitungskursbetreuung < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class LeitungKernaufgabeAusbildung < ::Role
    self.permissions = [:layer_full, :group_read, :contact_data, :approve_applications]
  end

  class LeitungKernaufgabeKommunikation < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class LeitungKernaufgabeProgramm < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class LeitungKernaufgabeSupport < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Mediensprecher < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Mitarbeiter < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class MitarbeiterGs < ::Role
    self.permissions = [:layer_and_below_full, :contact_data, :admin]
  end

  class MitgliedKrisenteam < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Passivmitglied < ::Role
    self.permissions = []
    self.kind = :passive
  end

  class Praesidium < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class PraesidiumApv < ::Role
    self.permissions = [:group_read]
  end

  class Redaktor < ::Role
    self.permissions = [:layer_and_below_read, :contact_data]
  end

  class Revisor < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Sekretariat < ::Role
    self.permissions = [:layer_and_below_full, :contact_data]
  end

  class Spezialfunktion < ::Role
    self.permissions = [:group_read]
  end

  class StvIcProgrammeWagggs < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class StvIcProgrammeWosm < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Uebersetzer < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungBiberstufe < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungIntegration < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungLagermeldung < ::Role
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

  class VerantwortungRoverstufe < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungWolfstufe < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VertretungPbs < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VizePraesidium < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Webmaster < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  roles MitarbeiterGs,
        Sekretariat,
        Adressverwaltung,
        AssistenzAusbildung,
        Praesidium,
        VizePraesidium,
        PraesidiumApv,
        Geschaeftsleitung,
        Mitarbeiter,
        VertretungPbs,
        Beisitz,

        Kassier,
        Revisor,
        Redaktor,
        Webmaster,
        Mediensprecher,
        Uebersetzer,
        MitgliedKrisenteam,

        Coach,
        GrossanlassCoach,
        Leitungskursbetreuung,

        LeitungKernaufgabeAusbildung,
        LeitungKernaufgabeKommunikation,
        LeitungKernaufgabeProgramm,
        LeitungKernaufgabeSupport,

        VerantwortungBiberstufe,
        VerantwortungWolfstufe,
        VerantwortungPfadistufe,
        VerantwortungPiostufe,
        VerantwortungRoverstufe,
        VerantwortungPfadiTrotzAllem,
        VerantwortungIntegration,
        VerantwortungLagermeldung,
        VerantwortungPr,
        VerantwortungPraeventionSexuellerAusbeutung,

        InternationalCommissionerIcWagggs,
        InternationalCommissionerIcWosm,
        StvIcProgrammeWagggs,
        StvIcProgrammeWosm,

        Spezialfunktion,

        Ehrenmitglied,
        Passivmitglied,
        Kontaktperson

end
