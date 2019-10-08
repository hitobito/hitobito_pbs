#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class SupercampsController < ApplicationController
  skip_authorization_check
  before_action :authorize, only: [:connect]

  helper_method :group, :camp_id
  decorates :group

  respond_to :js

  EXCLUDED_SUPERCAMP_ATTRS = %w(
    id type name state description
    expected_participants_wolf_f expected_participants_wolf_m
    expected_participants_pfadi_f expected_participants_pfadi_m
    expected_participants_pio_f expected_participants_pio_m
    expected_participants_rover_f expected_participants_rover_m
    expected_participants_leitung_f expected_participants_leitung_m
    parent_id allow_sub_camps group_ids
    maximum_participants
    leader abteilungsleitung al_present al_visiting al_visiting_date
    coach coach_visiting coach_visiting_date
    advisor_mountain_security advisor_snow_security advisor_water_security
    lagerreglement_applied kantonalverband_rules_applied j_s_rules_applied
  ).freeze

  EXCLUDED_DATES_ATTRS = %w(id event_id).freeze

  def available
    group
    supercamps_on_group_and_above
  end

  def connect
    flash[:event_with_merged_supercamp] = event_with_merged_supercamp
    redirect_to request.referer
  end

  private

  def group
    @group ||= Group.find(params[:group_id])
  end

  def supercamps_on_group_and_above
    @supercamps_on_group_and_above = group.decorate.supercamps_on_group_and_above(camp_id)
  end

  def camp_id
    @camp_id ||= params[:camp_id]
  end

  def supercamp
    @supercamp ||= Event.includes(:dates).find(params[:supercamp_id])
  end

  def dates_attributes
    supercamp.dates.map { |date| date.attributes.except(*EXCLUDED_DATES_ATTRS) }
  end

  def supercamp_attrs
    @supercamp_attrs ||= supercamp.attributes.except(*EXCLUDED_SUPERCAMP_ATTRS)
                           .merge({ dates_attributes: dates_attributes })
  end

  def event_with_merged_supercamp
    params[:event].merge(supercamp_attrs).merge({'parent_id' => params[:supercamp_id]})
  end

  def authorize
    authorize!(:show, supercamp)
  end

end
