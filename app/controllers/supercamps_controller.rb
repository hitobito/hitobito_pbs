# frozen_string_literal: true

#  Copyright (c) 2019-2021, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class SupercampsController < ApplicationController
  skip_authorization_check
  before_action :authorize, only: [:connect]

  helper_method :group, :camp_id
  decorates :group

  rescue_from CanCan::AccessDenied, with: :handle_access_denied
  respond_to :js, only: [:available, :query]

  EXCLUDED_SUPERCAMP_ATTRS = %w[
    id type name state
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
  ].freeze

  EXCLUDED_DATES_ATTRS = %w[id event_id].freeze

  EXCLUDED_QUESTIONS_ATTRS = %w[id event_id].freeze

  def available
    supercamps_on_group_and_above
  end

  def query
    @found_supercamps = []
    if params.key?(:q) && params[:q].size >= 3
      @found_supercamps = without_self_and_descendants(matching_supercamps.limit(10))
    end
  end

  def connect
    flash[:event_with_merged_supercamp] = event_with_merged_supercamp.to_unsafe_h
    redirect_back(fallback_location: group)
  end

  private

  def without_self_and_descendants(supercamps)
    return supercamps unless camp_id

    child_ids = Event::Camp.find(camp_id).self_and_descendants.pluck(:id)
    supercamps.reject { |supercamp| child_ids.include?(supercamp.id) }
  end

  def group
    @group ||= Group.find(params[:group_id])
  end

  def supercamps_on_group_and_above
    @supercamps_on_group_and_above = without_self_and_descendants(
      group.decorate.upcoming_supercamps_on_group_and_above
    )
  end

  def matching_supercamps
    Event::Camp.upcoming
               .left_joins(:translations)
               .where("event_translations.name ILIKE ?", "%#{params[:q]}%")
               .where(allow_sub_camps: true, state: "created").distinct
  end

  def camp_id
    @camp_id ||= params[:camp_id]
  end

  def supercamp
    @supercamp ||= Event.includes(:dates, :application_questions, :admin_questions)
      .find(params[:supercamp_id])
  end

  def dates_attributes
    supercamp.dates.map { |date| date.attributes.except(*EXCLUDED_DATES_ATTRS) }
  end

  def application_questions_attrs
    supercamp.application_questions.map do |question|
      question.attributes.except(*EXCLUDED_QUESTIONS_ATTRS).merge(pass_on_to_supercamp: true)
    end
  end

  def admin_questions_attrs
    supercamp.admin_questions.map do |question|
      question.attributes.except(*EXCLUDED_QUESTIONS_ATTRS).merge(pass_on_to_supercamp: true)
    end
  end

  def required_contact_attrs
    all_required_attrs = supercamp.required_contact_attrs +
      Event::ParticipationContactData.mandatory_contact_attrs

    all_required_attrs.index_with do |_attr|
      :required
    end
  end

  def supercamp_attributes_to_merge
    {
      dates_attributes: dates_attributes,
      application_questions_attributes: application_questions_attrs,
      admin_questions_attributes: admin_questions_attrs,
      contact_attrs: required_contact_attrs,
      contact_attrs_passed_on_to_supercamp: required_contact_attrs
    }
  end

  def supercamp_attrs
    @supercamp_attrs ||= supercamp.attributes.except(*EXCLUDED_SUPERCAMP_ATTRS)
      .merge(supercamp_attributes_to_merge)
  end

  def generated_name
    supercamp.name + ": " + group.display_name
  end

  def appended_description
    [
      params[:event][:description].to_s.strip,
      supercamp.description.to_s.strip
    ].join("\n\n").strip
  end

  def event_with_merged_supercamp
    params[:event]
      .merge(supercamp_attrs)
      .merge(parent_id: params[:supercamp_id],
        name: generated_name,
        description: appended_description)
  end

  def authorize
    authorize!(:show, supercamp)
    unless supercamp.allow_sub_camps
      raise CanCan::AccessDenied.new(I18n.t("supercamps.does_not_allow_sub_camps"),
        :connect, supercamp)
    end
    unless supercamp.state == "created"
      raise CanCan::AccessDenied.new(I18n.t("supercamps.not_in_created_state"),
        :connect, supercamp)
    end
    unless supercamp.upcoming
      raise CanCan::AccessDenied.new(I18n.t("supercamps.not_upcoming"), :connect, supercamp)
    end
    if params[:event]["parent_id"].present?
      raise CanCan::AccessDenied.new(I18n.t("supercamps.already_connected"), :connect, supercamp)
    end
  end

  def handle_access_denied(err)
    redirect_back(fallback_location: group, alert: err.message)
  end
end
