#  Copyright (c) 2012-2019, Pfadibewegung Schweiz. This file is part of
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

class Group::Abteilung < Group

  GENDERS = %w(m w).freeze

  GEOLOCATION_COUNT_LIMIT = 4
  GEOLOCATION_SWITZERLAND_NORTH_LIMIT = 47.811263
  GEOLOCATION_SWITZERLAND_SOUTH_LIMIT = 45.811958
  GEOLOCATION_SWITZERLAND_EAST_LIMIT = 10.523665
  GEOLOCATION_SWITZERLAND_WEST_LIMIT = 5.922318

  CONTENT_GROUPFINDER_FIELDS_INFO = 'groupfinder_fields_info'.freeze

  self.layer = true
  self.event_types = [Event, Event::Course, Event::Camp]

  self.used_attributes += [:pta, :vkp, :group_health, :pbs_material_insurance, :gender,
                           :try_out_day_at, :geolocations]
  self.superior_attributes += [:pta, :vkp, :pbs_material_insurance]

  children Group::Biber,
           Group::Woelfe,
           Group::Pfadi,
           Group::Pio,
           Group::AbteilungsRover,
           Group::Pta,
           Group::Elternrat,
           Group::AbteilungsGremium

  has_many :member_counts # rubocop:disable Rails/HasManyOrHasOneDependent since groups are only soft-deleted
  has_many :geolocations, as: :geolocatable, dependent: :destroy
  accepts_nested_attributes_for :geolocations,
                                allow_destroy: true,
                                reject_if: proc { |c| c[:lat].blank? && c[:long].blank? }
  # Can't use the limit parameter on  accepts_nested_attributes_for because it
  # still counts in the rejected records
  # Can't use validates :geolocations, length: { ... } because it counts in the
  # nested records that are #marked_for_destruction?
  validate :assert_geolocation_count
  validate do
    is_valid = geolocations.all? do |geolocation|
      GEOLOCATION_SWITZERLAND_SOUTH_LIMIT < geolocation.lat.to_f \
      && geolocation.lat.to_f < GEOLOCATION_SWITZERLAND_NORTH_LIMIT \
      && GEOLOCATION_SWITZERLAND_WEST_LIMIT < geolocation.long.to_f \
      && geolocation.long.to_f < GEOLOCATION_SWITZERLAND_EAST_LIMIT
    end
    errors.add(:base, :geo_not_in_switzerland) if !is_valid
  end

  include I18nEnums
  i18n_enum :gender, GENDERS
  include I18nSettable
  i18n_setter :gender, (GENDERS + [nil])

  ### INSTANCE METHODS

  def kantonalverband
    ancestors.find_by(type: Group::Kantonalverband.sti_name)
  end

  def region
    ancestors.where(type: Group::Region.sti_name).order('lft DESC').first
  end

  def census_groups(_year)
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

  private

  def assert_geolocation_count
    if geolocations.reject(&:marked_for_destruction?).size > GEOLOCATION_COUNT_LIMIT
      errors.add(:geolocations, :too_many_geolocations, max: GEOLOCATION_COUNT_LIMIT)
    end
  end


  ### ROLES

  class Abteilungsleitung < ::Role
    self.permissions = [:layer_and_below_full, :contact_data, :approve_applications]
  end

  class AbteilungsleitungStv < ::Role
    self.permissions = [:layer_and_below_full, :contact_data, :approve_applications]
  end

  class Adressverwaltung < ::Role
    self.permissions = [:group_and_below_full]
  end
  class PowerUser < Adressverwaltung; end

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

  class Heimverwaltung < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Kassier < ::Role
    self.permissions = [:layer_and_below_read, :contact_data]
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

  class StufenleitungBiber < ::Role
    self.permissions = [:layer_and_below_read]
  end

  class StufenleitungWoelfe < ::Role
    self.permissions = [:layer_and_below_read]
  end

  class StufenleitungPfadi < ::Role
    self.permissions = [:layer_and_below_read]
  end

  class StufenleitungPio < ::Role
    self.permissions = [:layer_and_below_read]
  end

  class StufenleitungRover < ::Role
    self.permissions = [:layer_and_below_read]
  end

  class StufenleitungPta < ::Role
    self.permissions = [:layer_and_below_read]
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
        PowerUser,
        Praesidium,
        VizePraesidium,
        PraesidiumApv,
        Praeses,
        Beisitz,
        Materialwart,
        Heimverwaltung,

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
