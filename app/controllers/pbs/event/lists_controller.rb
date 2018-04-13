# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ListsController
  extend ActiveSupport::Concern

  included do
    skip_authorization_check only: :camps
    skip_authorize_resource only: [:camps, :all_camps, :kantonalverband_camps,
                                   :camps_in_canton, :camps_abroad]
  end

  # simple redirect action acting as a generic entry point from the main navigation
  def camps
    if can?(:list_all, Event::Camp)
      redirect_to list_all_camps_path
    elsif can?(:list_abroad, Event::Camp)
      redirect_to list_camps_abroad_path
    elsif can?(:list_cantonal, Event::Camp)
      role = current_user.roles.find do |role|
        EventAbility::CANTONAL_CAMP_LIST_ROLES.any? { |t| role.is_a?(t) }
      end
      redirect_to list_kantonalverband_camps_path(group_id: role.group_id)
    else
      raise(CanCan::AccessDenied)
    end
  end

  # List all camps everywhere coming up.
  def all_camps
    authorize!(:list_all, Event::Camp)

    @nav_left = 'camps'
    render_camp_list(all_upcoming_camps)
  end

  # List camps organized by the given Kantonalverband.
  def kantonalverband_camps
    authorize!(:list_cantonal, Event::Camp)

    @nav_left = 'camps'
    @group = Group::Kantonalverband.find(params[:group_id])
    render_camp_list(all_kantonalverband_camps)
  end

  # List camps taking place in the given canton.
  def camps_in_canton
    authorize!(:list_cantonal, Event::Camp)

    @nav_left = 'camps'
    render_camp_list(all_camps_in_canton)
  end

  # List camps taking place abroad.
  def camps_abroad
    authorize!(:list_abroad, Event::Camp)

    @nav_left = 'camps'
    render_camp_list(all_camps_abroad)
  end

  private

  def render_camp_list(camps)
    respond_to do |format|
      format.html  { @camps = grouped(camps) }
      format.csv   { render_camp_csv(camps) }
    end
  end

  def render_camp_csv(camps)
    send_data Export::Tabular::Events::List.csv(camps), type: :csv
  end

  def all_upcoming_camps
    in_next_three_weeks(base_camp_query('canceled').upcoming)
  end

  def all_kantonalverband_camps
    base_camp_query.
      joins(:groups).
      where('groups.lft >= ? AND groups.rgt <= ?', @group.lft, @group.rgt).
      in_year(year)
  end

  def all_camps_in_canton
    in_next_three_weeks(base_camp_query.
      where(canton: params[:canton]).
      upcoming)
  end

  def all_camps_abroad
    base_camp_query.
      where(canton: Event::Camp::ABROAD_CANTON).
      in_year(year)
  end

  def base_camp_query(excluded_states = %w(created canceled))
    Event::Camp.
      where(camp_submitted: true).
      where.not(state: excluded_states).
      includes(:groups).
      list
  end

  def in_next_three_weeks(scope)
    timespan = Time.zone.now.midnight + 3.weeks
    scope.where('event_dates.start_at <= ? OR event_dates.finish_at <= ?', timespan, timespan)
  end

end
