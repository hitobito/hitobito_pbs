# encoding: utf-8

#  Copyright (c) 2020, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class GroupHealthController < ApplicationController

  J_S_KINDS = %w(j_s_kind_none j_s_kind_j_s_child j_s_kind_j_s_youth j_s_kind_j_s_mixed).freeze
  CAMP_STATES = %w(created confirmed assignment_closed canceled closed).freeze
  GROUP_HEALTH_JOIN = 'INNER JOIN groups AS layer ON groups.layer_group_id = layer.id AND' \
    ' layer.group_health = TRUE'.freeze
  DEFAULT_PAGE_SIZE = 20.freeze

  before_action do
    authorize! :show, GroupHealthController
  end

  # json only controller
  respond_to :html, only: []
  respond_to :json

  def people
    render json: Person.joins(roles: :group).joins(GROUP_HEALTH_JOIN).distinct
                     .page(params[:page]).per(params[:size] || DEFAULT_PAGE_SIZE)
                     .as_json(only: [:id, :pbs_number, :first_name, :last_name, :nickname, :address,
                                     :town, :zip_code, :country, :gender, :birthday, :entry_date,
                                     :leaving_date, :primary_group_id])
                     .map {|h| h.except('first_name', 'last_name', 'nickname')
                     .merge({name: h['nickname'].blank? ? '%s %s.' % [h['first_name'],
                       (h['last_name'] || '').first] : h['nickname']})}
  end

  def roles
    render json: Role.joins(:group).joins(GROUP_HEALTH_JOIN)
                     .page(params[:page]).per(params[:size] || DEFAULT_PAGE_SIZE)
                     .as_json(only: [:id, :person_id, :group_id, :type, :created_at, :deleted_at])
  end

  def groups
    render json: Group.joins(GROUP_HEALTH_JOIN + ' OR groups.type = "Group::Bund" OR' \
      ' groups.type = "Group::Kantonalverband"' \
      ' LEFT JOIN groups AS canton ON groups.lft >= canton.lft' \
      ' AND groups.lft < canton.rgt AND canton.type = "Group::Kantonalverband"')
                     .distinct
                     .select('groups.*', 'canton.id as canton_id', 'canton.name as canton_name')
                     .page(params[:page]).per(params[:size] || DEFAULT_PAGE_SIZE)
                     .as_json(only: [:id, :parent_id, :type, :name, :created_at, :deleted_at,
                                     :canton_id, :canton_name])
  end

  def courses
    render json: Event.joins(people: [{roles: :group}]).joins(GROUP_HEALTH_JOIN).distinct
                     .includes(:dates, :groups).where(type: 'Event::Course')
                     .as_json(only: [:id, :name, :kind_id],
                              include: {dates: {only: [:start_at, :finish_at]},
                                        groups: {only: :id}})
  end

  def camps
    render json: Event.joins(people: [{ roles: :group }]).joins(GROUP_HEALTH_JOIN).distinct
                     .includes(:dates, :groups).where(type: 'Event::Camp')
                     .as_json(only: [:id, :name, :location, :j_s_kind, :state],
                              include: { dates: { only: [:start_at, :finish_at] },
                                         groups: { only: :id } })
                     .map { |h|
                       h['j_s_kind'] = h['j_s_kind'].present? ? "j_s_kind_#{h['j_s_kind']}" :
                                           'j_s_kind_none'
                       h
                     }
  end

  def participations
    render json: Event::Participation.joins(person: [{ roles: :group }])
                     .joins(GROUP_HEALTH_JOIN).distinct
                     .page(params[:page]).per(params[:size] || DEFAULT_PAGE_SIZE)
                     .includes(:roles).as_json(only: [:id, :event_id, :person_id, :qualified],
                                               include: { roles: { only: :type } })
  end

  def qualifications
    render json: Qualification.joins(person: [{ roles: :group }])
                     .joins(GROUP_HEALTH_JOIN).distinct.as_json()
  end

  def qualification_kinds
    data = QualificationKind.includes(:translations)
               .as_json(only: [:id, :label, :validity],
                        include: { translations: { only: [:locale, :label] } })
    render json: flatten_translations(data, 'label')
  end

  def event_kinds
    data = Event::Kind.includes(:translations, :event_kind_qualification_kinds)
               .as_json(only: :id,
                        include: { translations: { only: [:locale, :label] },
                                   event_kind_qualification_kinds: { only: [:qualification_kind_id,
                                                                            :role, :category] } })
    render json: flatten_translations(data, 'label')
  end

  def role_types
    data = []
    Role::TypeList.new(Group.root_types.first).each do |layer, groups|
      groups.each do |group, roles|
        roles.each do |r|
          data.push({ role_type: r.model_name, layer_type: layer, group_type: group }
                        .merge(localize_labels_type(r)))
        end
      end
    end
    render json: data
  end

  def group_types
    data = []
    Group.all_types.each do |t|
      data.push({ group_type: t.model_name }.merge(localize_labels_type(t)))
    end
    render json: data
  end

  def participation_types
    data = []
    symbols = [Event, Event::Course, Event::Camp]
    symbols.each do |s|
      s.role_types.each do |t|
        if not data.include? t.model_name then
          data.push({ participation_type: t.model_name }.merge(localize_labels_type(t)))
        end
      end
    end
    render json: data
  end

  def j_s_kinds
    data = []
    J_S_KINDS.each do |k|
      data.push({ j_s_kind: k }.merge(localize_labels("events.fields_pbs.#{k}")))
    end
    render json: data
  end

  def camp_states
    data = []
    CAMP_STATES.each do |s|
      data.push({ state: s }.merge(
          localize_labels("activerecord.attributes.event/camp.states.#{s}")))
    end
    render json: data
  end

  private

  def flatten_translations(items, key)
    items.map {|h| h.except('translations', key).merge(h['translations']
      .map {|t| [['%s_%s' % [key, t['locale']], t['label']]].to_h}.inject(:merge))
                       .merge(empty_labels) { |key, v1, v2| v1 }}
  end

  def locales
    @locales ||= [:de, :fr, :it]
  end

  def empty_labels
    @empty_labels ||= locales.map {|loc| [['label_%s' % loc, nil]].to_h}.inject(:merge)
  end

  def localize_labels(identifier)
    locales.map {|loc|
      I18n.locale = loc
      ["label_#{loc}", I18n.t(identifier)]
    }.to_h
  end

  def localize_labels_type(type)
    locales.map {|loc|
      I18n.locale = loc
      ["label_#{loc}", type.label]
    }.to_h
  end
end
