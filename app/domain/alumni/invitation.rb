# encoding: utf-8

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module People
  class AlumniInvitation
    attr_reader :role, :type

    def initialize(role, type)
      @role = role
      @type = type
      raise "Unknown type: #{type}" unless AlumniMailer.respond_to?(:type)
    end

    def process
      set_timestamp
      send_invitation if conditions_met?
    end

    private

    def set_timestamp
      role.update(alumni_invitation_processed_at: Time.zone.now)
    end

    def conditions_met?
      no_active_role_in_layer? &&
        old_enough_if_in_age_group? &&
        applicable_role? &&
        person_has_main_email? &&
        person_has_no_former_member_role?
    end

    def no_active_role_in_layer?
      ! Role.
        joins(:group).
        where(person_id: role.person_id, group: {layer_group_id: role.layer_group_id}).
        exist?
    end

    def old_enough_if_in_age_group?
      return true unless [Group::Biber, Group::Woelfe, Group::Pfadi, Group::Pio, Group::Pta].include?(role.group)

      role.person.birthday.present? && role.person.birthday <= 16.years.ago.to_date
    end

    def applicable_role?
      [Group::Ehemalige::Mitglied, Group::Ehemalige::Leitung].exclude?(role) &&
        [Group::Silverscouts::Region, Group::Silverscouts, Group::Root].exclude?(role.group)
    end

    def person_has_main_email?
      role.person.email.present?
    end

    def person_has_no_former_member_role?
      role.person.roles.none? do |role|
        [Group::Ehemalige::Mitglied, Group::Ehemalige::Leitung].include?(role) ||
          [Group::Silverscouts::Region, Group::Silverscouts, Group::Root].include?(role.group)
      end
    end

    def send_invitation
      return unless FeatureGate.enabled?('silverscouts.invitation')

      groups = ApplicableGroups.new(role)
      AlumniMailer.send(type, role.person, groups.alumni_groups, groups.silverscout_groups).deliver_later
    end
  end
end
