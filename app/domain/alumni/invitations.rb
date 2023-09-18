# encoding: utf-8

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module People
  class AlumniInvitations
    class_attribute :time_range, default: 6.months.ago..3.months.ago
    class_attribute :type, default: :invitation

    def process
      relevant_roles.each do |role|
        AlumniInvitation.new(role, type).process
      end
    end

    private

    def relevant_roles
      Role.includes(:person, group: :layer_group).where(deleted_at: time_range, alumni_invitation_processed_at: nil)
    end
  end
end
