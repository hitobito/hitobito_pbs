# encoding: utf-8

#  Copyright (c) 2020, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class GroupHealthController < ApplicationController

  EVENT_TYPES = [Event, Event::Course, Event::Camp].freeze
  J_S_KINDS = %w(j_s_kind_none j_s_kind_j_s_child j_s_kind_j_s_youth j_s_kind_j_s_mixed).freeze
  CAMP_STATES = %w(created confirmed assignment_closed canceled closed).freeze
  PERSON_FIELDS = %i(id pbs_number first_name last_name nickname address town zip_code country
                      gender birthday entry_date leaving_date primary_group_id).freeze
  ROLES_FIELDS = %i(id person_id group_id type created_at deleted_at).freeze
  GROUPS_FIELDS = %i(id parent_id type name created_at deleted_at canton_id canton_name).freeze
  COURSES_FIELDS = %i(id name kind_id).freeze
  CAMPS_FIELDS = %i(id name location j_s_kind state).freeze
  EVENT_DATES_FIELDS = %i(start_at finish_at).freeze
  EVENT_GROUPS_FIELDS = %i(id).freeze
  PARTICIPATIONS_FIELDS = %i(id event_id person_id qualified).freeze
  PARTICIPATIONS_ROLES_FIELDS = %i(type).freeze
  QUALIFICATION_KINDS_FIELDS = %i(id label validity).freeze
  TRANSLATIONS_FIELDS = %i(locale label).freeze
  EVENT_KINDS_FIELDS = %i(id).freeze
  # event_kind_qualification_kinds
  EKQK_FIELDS = %i(qualification_kind_id role category).freeze


  GROUP_HEALTH_JOIN = 'INNER JOIN groups AS layer ON groups.layer_group_id = layer.id AND' \
      ' layer.group_health = TRUE'.freeze
  GROUPS_JOIN = GROUP_HEALTH_JOIN + ' OR groups.type = "Group::Bund" OR' \
      ' groups.type = "Group::Kantonalverband"' \
      ' LEFT JOIN groups AS canton ON groups.lft >= canton.lft' \
      ' AND groups.lft < canton.rgt AND canton.type = "Group::Kantonalverband"'.freeze
  DEFAULT_PAGE_SIZE = 20.freeze

  before_action do
    authorize! :show, GroupHealthController
  end

  # json only controller
  respond_to :html, only: []
  respond_to :json

  def people
    respond(Person.joins(roles: :group)
                .joins(GROUP_HEALTH_JOIN).distinct
                .page(params[:page]).per(params[:size] || DEFAULT_PAGE_SIZE)
                .as_json(only: PERSON_FIELDS)
                .map { |item| set_name(item) })
  end

  def roles
    respond(Role.joins(:group)
                .joins(GROUP_HEALTH_JOIN).distinct
                .page(params[:page]).per(params[:size] || DEFAULT_PAGE_SIZE)
                .as_json(only: ROLES_FIELDS))
  end

  def groups
    respond(Group.select('groups.*', 'canton.id as canton_id', 'canton.name as canton_name')
                .joins(GROUPS_JOIN).distinct
                .page(params[:page]).per(params[:size] || DEFAULT_PAGE_SIZE)
                .as_json(only: GROUPS_FIELDS))
  end

  def courses
    respond(Event::Course.joins(people: [{ roles: :group }])
                .joins(GROUP_HEALTH_JOIN).distinct
                .includes(:dates, :groups)
                .page(params[:page]).per(params[:size] || DEFAULT_PAGE_SIZE)
                .as_json(only: COURSES_FIELDS,
                         include: { dates: { only: EVENT_DATES_FIELDS },
                                    groups: { only: EVENT_GROUPS_FIELDS } }))
  end

  def camps
    respond(Event::Camp.joins(people: [{ roles: :group }])
                .joins(GROUP_HEALTH_JOIN).distinct
                .includes(:dates, :groups)
                .page(params[:page]).per(params[:size] || DEFAULT_PAGE_SIZE)
                .as_json(only: CAMPS_FIELDS,
                         include: { dates: { only: EVENT_DATES_FIELDS },
                                    groups: { only: EVENT_GROUPS_FIELDS } })
                .map { |camp| set_j_s_kind(camp) })
  end

  def participations
    respond(Event::Participation.joins(person: [{ roles: :group }])
                .joins(GROUP_HEALTH_JOIN).distinct
                .page(params[:page]).per(params[:size] || DEFAULT_PAGE_SIZE)
                .includes(:roles)
                .as_json(only: PARTICIPATIONS_FIELDS,
                         include: { roles: { only: PARTICIPATIONS_ROLES_FIELDS } }))
  end

  def qualifications
    respond(Qualification.joins(person: [{ roles: :group }])
                .joins(GROUP_HEALTH_JOIN).distinct
                .page(params[:page]).per(params[:size] || DEFAULT_PAGE_SIZE)
                .as_json)
  end

  def qualification_kinds
    respond(QualificationKind.includes(:translations)
                .as_json(only: QUALIFICATION_KINDS_FIELDS,
                         include: { translations: { only: TRANSLATIONS_FIELDS } })
                .map { |item| set_translations(item, 'label') })
  end

  def event_kinds
    respond(Event::Kind.includes(:translations, :event_kind_qualification_kinds)
                .as_json(only: EVENT_KINDS_FIELDS,
                         include: { translations: { only: TRANSLATIONS_FIELDS },
                                    event_kind_qualification_kinds: { only: EKQK_FIELDS } }
                )
                .map { |item| set_translations(item, 'label') })
  end

  def role_types
    respond(Role::TypeList.new(Group.root_types.first).flatten do |role, group, layer|
      localize_type_labels(role)
          .merge(role_type: role.model_name, group_type: group, layer_type: layer)
    end)
  end

  def group_types
    respond(Group.all_types.map do |type|
      localize_type_labels(type).merge(group_type: type.model_name)
    end)
  end

  def participation_types
    respond(EVENT_TYPES.flat_map do |event_type|
      event_type.role_types.map do |role_type|
        localize_type_labels(role_type).merge(participation_type: role_type.model_name)
      end
    end.uniq)
  end

  def j_s_kinds
    respond(J_S_KINDS.map do |kind|
      localize_labels("events.fields_pbs.#{kind}").merge(j_s_kind: kind)
    end)
  end

  def camp_states
    respond(CAMP_STATES.map do |state|
      localize_labels("activerecord.attributes.event/camp.states.#{state}")
          .merge(state: state)
    end)
  end

  private

  def respond(data)
    respond_with({ action_name => data })
  end

  def set_name(person)
    person.except('first_name', 'last_name', 'nickname')
        .merge(name: computed_name(person))
  end

  def computed_name(person)
    return person['nickname'] unless person['nickname'].blank?
    [person['first_name'], (person['last_name'] || '').first].join(' ')
  end

  def set_j_s_kind(camp)
    camp.merge('j_s_kind' => "j_s_kind_#{camp.fetch('j_s_kind', 'none')}")
  end

  def set_translations(item, key)
    item.except(key, 'translations')
        .merge(empty_translations_hash(key))
        .merge(translations_to_hash(item['translations'], key))
  end

  def empty_translations_hash(key)
    locales.map { |loc| ["#{key}_#{loc}", nil] }.to_h
  end

  def translations_to_hash(translations, key)
    translations.map { |t| ["#{key}_#{t['locale']}", t['label']] }.to_h
  end

  def locales
    @locales ||= Settings.application.languages.keys
  end

  def localize_labels(identifier)
    locales.map do |loc|
      I18n.locale = loc
      ["label_#{loc}", I18n.t(identifier)]
    end.to_h
  end

  def localize_type_labels(type)
    locales.map do |loc|
      I18n.locale = loc
      ["label_#{loc}", type.label]
    end.to_h
  end
end
