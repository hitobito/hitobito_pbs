# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class AddCampFieldsToEvents < ActiveRecord::Migration

  def change

    # expected participants
    add_column :events, :expected_participants_wolf_f, :integer
    add_column :events, :expected_participants_wolf_m, :integer
    add_column :events, :expected_participants_pfadi_f, :integer
    add_column :events, :expected_participants_pfadi_m, :integer
    add_column :events, :expected_participants_pio_f, :integer
    add_column :events, :expected_participants_pio_m, :integer
    add_column :events, :expected_participants_rover_f, :integer
    add_column :events, :expected_participants_rover_m, :integer
    add_column :events, :expected_participants_leitung_f, :integer
    add_column :events, :expected_participants_leitung_m, :integer

    # camp days
    add_column :events, :camp_days, :decimal, precision: 5, scale: 1

    # camp location
    add_column :events, :camp_location, :string
    add_column :events, :camp_location_address, :string
    add_column :events, :camp_location_coordinates, :string
    add_column :events, :camp_location_altitude, :string
    add_column :events, :camp_location_emergency_phone, :string
    add_column :events, :camp_location_owner, :string
    add_column :events, :camp_location_approved, :boolean, null: false, default: false

    # j+s fields
    add_column :events, :j_s_kind, :integer
    add_column :events, :j_s_security_snow, :boolean, null: false, default: false
    add_column :events, :j_s_security_mountain, :boolean, null: false, default: false
    add_column :events, :j_s_security_water, :boolean, null: false, default: false

    # participants can unsubscribe 
    add_column :events, :participants_can_apply, :boolean, null: false, default: false
    add_column :events, :participants_can_cancel, :boolean, null: false, default: false

    # AL presence
    add_column :events, :al_present, :boolean, null: false, default: false
    add_column :events, :al_visiting, :boolean, null: false, default: false
    add_column :events, :al_visiting_date, :date

    # coach
    add_column :events, :coach_visiting, :boolean, null: false, default: false
    add_column :events, :coach_visiting_date, :date
    add_column :events, :coach_confirmed, :boolean, null: false, default: false

    # local scout
    add_column :events, :local_scout_contact_present, :boolean, null: false, default: false
    add_column :events, :local_scout_contact, :text

    # submitted to pbs ?
    add_column :events, :camp_submitted, :boolean, null: false, default: false

  end

end
