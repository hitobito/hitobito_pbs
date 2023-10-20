# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module HostnamedGroups
  extend ActiveSupport::Concern

  included do
    prepend_before_action :determine_group_by_hostname
  end

  # Initialize @group by matching the current request hostname.
  # This is used in LayoutHelper#header_logo to show a specific group logo depending on the hostname
  def determine_group_by_hostname
    @group ||= Group.where(hostname: request.host).first
  end
end
