#  Copyright (c) 2012-2021, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Person::HouseholdsController
  extend ActiveSupport::Concern

  included do
    alias_method_chain :permitted_address_fields, :pbs_fields
  end

  protected

  def permitted_address_fields_with_pbs_fields
    permitted_address_fields_without_pbs_fields + %i[prefers_digital_correspondence]
  end
end
