# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Alumni
  class Invitations
    class_attribute :type, default: :invitation

    def process
      relevant_roles.each { |role| Alumni::Invitation.new(role, type).process }
    end

    def relevant_roles
      Role.
        with_deleted.
        where(deleted_at: time_range, alumni_invitation_processed_at: nil).
        includes(:person, :group)
    end

    def time_range
      from = parse_duration(:alumni, :invitation, :role_deleted_after_ago)
      to = parse_duration(:alumni, :invitation, :role_deleted_before_ago)
      from.ago..to.ago
    end

    private

    def parse_duration(*settings_path)
      iso8601duration = Settings.dig(*settings_path)
      ActiveSupport::Duration.parse(iso8601duration)
    rescue ActiveSupport::Duration::ISO8601Parser::ParsingError, ArgumentError
      raise "Value #{iso8601duration.inspect} at Settings.#{settings_path.join('')} " +
              'is not a valid ISO8601 duration'
    end
  end
end
