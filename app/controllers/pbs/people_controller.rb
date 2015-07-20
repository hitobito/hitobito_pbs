# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::PeopleController
  extend ActiveSupport::Concern

  included do
    self.permitted_attrs += [:salutation, :title, :grade_of_school, :entry_date,
                             :leaving_date, :j_s_number, :correspondence_language,
                             :brother_and_sisters]

    skip_load_and_authorize_resource only: [:query_tentative]
  end

  def query_tentative
    authorize!(:query, Person)
    people = []

    if params.key?(:q) && params[:q].size >= 3
      people = Person.where(search_condition(*PeopleController::QUERY_FIELDS)).
                      includes(roles: :group).
                      only_public_data.
                      order_by_name.
                      accessible_by(current_ability).
                      limit(10).
                      select { |p| can?(:update, p) }

      people = people.map { |p| p.decorate }
    end

    render json: people.collect(&:as_typeahead)
  end

end
