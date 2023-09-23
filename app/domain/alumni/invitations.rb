# encoding: utf-8
# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Alumni
  class Invitations
    class_attribute :time_range, default: -> { 6.months.ago..3.months.ago }
    class_attribute :type, default: :invitation

    def process
      relevant_roles.each { |role| Alumni::Invitation.new(role, type).process }
    end

    def relevant_roles
      Role.
        with_deleted.
        where(deleted_at: time_range.call, alumni_invitation_processed_at: nil).
        includes(:person, :group)
    end
  end
end
