#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Events::CoursesController
  extend ActiveSupport::Concern

  prepended do
    # required to allow api calls
    protect_from_forgery with: :null_session, only: [:bsv_export]
  end

  private

  def render_bsv_export(courses_for_bsv_export)
    if params[:advanced]
      send_data(Export::Tabular::Events::AdvancedBsvList.csv(courses_for_bsv_export),
        type: :csv, filename: "advanced_bsv_export.csv")
    else
      super
    end
  end
end
