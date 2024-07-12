# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Alumni
  class Invitation
    AGE_GROUPS = [
      Group::Biber, Group::Woelfe, Group::Pfadi, Group::Pio, Group::Pta
    ].freeze

    ALUMNI_ROLES = [Group::Ehemalige::Mitglied, Group::Ehemalige::Leitung].freeze

    SILVERSCOUT_GROUPS = [Group::Silverscouts, Group::SilverscoutsRegion].freeze

    attr_reader :role, :type, :alumni_groups

    def initialize(role, type, alumni_groups = ApplicableGroups.new(role))
      @role = role
      @type = type
      @alumni_groups = alumni_groups
      raise "Unknown type: #{type}" unless AlumniMailer.respond_to?(type)
    end

    def process
      set_timestamp
      send_invitation if conditions_met?
    end

    def conditions_met?
      feature_enabled? &&
        no_active_role_in_layer? &&
        old_enough_if_in_age_group? &&
        applicable_role? &&
        person_has_main_email? &&
        person_has_no_alumni_role?
    end

    def feature_enabled?
      FeatureGate.enabled?("alumni.invitation")
    end

    def no_active_role_in_layer?
      !Role
        .joins(:group)
        .where(person_id: role.person_id, group: {layer_group_id: role.group.layer_group_id})
        .exists?
    end

    def old_enough_if_in_age_group?
      return true unless AGE_GROUPS.include?(role.group.class)

      role.person.birthday.present? && role.person.birthday <= 16.years.ago.to_date
    end

    def applicable_role?
      ALUMNI_ROLES.exclude?(role.class) &&
        SILVERSCOUT_GROUPS.exclude?(role.group.class) &&
        !role.group.is_a?(Group::Root)
    end

    def person_has_main_email?
      role.person.email.present?
    end

    def person_has_no_alumni_role?
      role.person.roles.none? do |role|
        ALUMNI_ROLES.include?(role.class) ||
          SILVERSCOUT_GROUPS.include?(role.group.class) ||
          role.group.is_a?(Group::Root)
      end
    end

    private

    def set_timestamp
      timestamp_attr = "alumni_#{type}_processed_at"
      role.update!(timestamp_attr => Time.zone.now)
    end

    def send_invitation
      AlumniMailer.send(type, role.person, alumni_groups.ex_members_group_ids.presence,
        alumni_groups.silverscout_group_ids.presence)
        .deliver_later
    end
  end
end
