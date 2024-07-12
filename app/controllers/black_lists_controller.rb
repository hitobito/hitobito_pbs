#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class BlackListsController < SimpleCrudController
  self.permitted_attrs = [:first_name, :last_name, :pbs_number, :email,
    :phone_number, :reference_name, :reference_phone_number]

  def list_entries
    super.page(params[:page])
  end

  private

  def permitted_params
    model_params.permit(permitted_attrs)
  end
end
