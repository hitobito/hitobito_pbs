# encoding: utf-8

#  Copyright (c) 2020, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class HealthcheckController < ApplicationController

  J_S_KINDS = %w(j_s_kind_none j_s_kind_j_s_child j_s_kind_j_s_youth j_s_kind_j_s_mixed).freeze
  CAMP_STATES = %w(created confirmed assignment_closed canceled closed).freeze

  def show
    authorize! :show, HealthcheckController
    render json: render_json
  end

  private

  def render_json
    data = {}
    tables = ['group_types', 'role_types', 'participation_types', 'j_s_kinds', 'camp_states', 'qualification_kinds', 'event_kinds',
      'people', 'groups', 'courses', 'camps', 'roles', 'participations', 'qualifications']
    tables.each do |t|
      data[t] = self.send(t)
    end
    return data
  end

  def people
    Person.all.as_json(only: [:id, :first_name, :last_name, :nickname, :address, :town,
      :zip_code, :country, :gender, :birthday, :entry_date, :leaving_date, :primary_group_id])
  end

  def roles
    Role.all.as_json(only: [:id, :person_id, :group_id, :type, :created_at, :deleted_at])
      .map {|h| h.except('type').merge({type_id: map_role(h['type'])})}
  end

  def groups
    Group.all.as_json(only: [:id, :lft, :parent_id, :type, :name, :created_at, :deleted_at])
      .map {|h|
        canton = Group.where(':lft >= groups.lft AND :lft < groups.rgt AND ' \
          'type = :type', {lft: h['lft'], type: 'Group::Kantonalverband'}).first.as_json(only: [:id, :name])
        h.except('lft', 'type').merge({canton_id: canton.nil? ? nil : canton['id'], type_id: map_group(h['type'])})
      }
  end

  def courses
    Event.includes(:dates, :groups).where(type: 'Event::Course')
      .as_json(only: [:id, :name, :kind_id], include: {dates: {only: [:start_at, :finish_at]}, groups: {only: :id}})
  end

  def camps
    Event.includes(:dates, :groups).where(type: 'Event::Camp')
      .as_json(only: [:id, :name, :location, :kind_id, :j_s_kind, :state],
        include: {dates: {only: [:start_at, :finish_at]}, groups: {only: :id}})
      .map {|h|
        h['j_s_kind_id'] = map_j_s_kind(h['j_s_kind'].present? ? "j_s_kind_#{h['j_s_kind']}" : 'j_s_kind_none')
        h['state_id'] = map_camp_state(h['state'])
        h.except('j_s_kind', 'state')
      }
  end

  def participations
    Event::Participation.includes(:roles).as_json(only: [:id, :event_id, :person_id, :qualified],
      include: {roles: {only: :type}})
      .map {|h|
        h['roles'] = h['roles'].map {|r| {type_id: map_participation(r['type'])}}
        h
      }
  end

  def qualifications
    Qualification.all.as_json()
  end

  def flatten_translations(items, key)
    return items.map {|h| h.except('translations', key)
      .merge(h['translations'].map {|t| [['%s_%s' % [key, t['locale']], t['label']]].to_h}.inject(:merge))}
  end

  def qualification_kinds
    data = QualificationKind.includes(:translations)
      .as_json(only: [:id, :label, :validity],
      include: {translations: {only: [:locale, :label]}})
    return flatten_translations(data, 'label')
  end

  def event_kinds
    data = Event::Kind.includes(:translations, :event_kind_qualification_kinds)
      .as_json(only: :id,
      include: {translations: {only: [:locale, :label]},
      event_kind_qualification_kinds: {only: [:qualification_kind_id, :role, :category]}})
    return flatten_translations(data, 'label')
  end

  def role_types
    data = []
    id = 0
    @role_mapping = {}
    Role::TypeList.new(Group.root_types.first).each do |layer, groups|
      groups.each do |group, roles|
        roles.each do |r|
          labels_localized = locales.map {|loc|
            I18n.locale = loc
            ["label_#{loc}", r.label]
          }.to_h
          data.push({id: id, layer_type: layer, group_type: group, role_type: r.model_name}.merge(labels_localized))
          @role_mapping[r.model_name.to_s] = id
          id += 1
        end
      end
    end
    return data
  end

  def group_types
    data = []
    @group_mapping = {}
    Group.all_types.each_with_index do |t, i|
      labels_localized = locales.map {|loc|
        I18n.locale = loc
        ["label_#{loc}", t.label]
      }.to_h
      data.push({id: i, group_type: t.model_name}.merge(labels_localized))
      @group_mapping[t.model_name.to_s] = i
    end
    return data
  end

  def participation_types
    data = []
    id = 0
    @participation_mapping = {}
    symbols = [Event, Event::Course, Event::Camp]
    symbols.each do |s|
      s.role_types.each do |t|
        if not data.include? t.model_name then
          labels_localized = locales.map {|loc|
            I18n.locale = loc
            ["label_#{loc}", t.label]
          }.to_h
          data.push({id: id, participation_type: t.model_name}.merge(labels_localized))
          @participation_mapping[t.model_name.to_s] = id
          id += 1
        end
      end
    end
    return data
  end

  def j_s_kinds
    data = []
    @j_s_kind_mapping = {}
    J_S_KINDS.each_with_index do |k, i|
      labels_localized = locales.map {|loc|
        I18n.locale = loc
        ["label_#{loc}", I18n.t("events.fields_pbs.#{k}")]
      }.to_h
      data.push({id: i, j_s_kind: k}.merge(labels_localized))
      @j_s_kind_mapping[k] = i
    end
    return data
  end

  def camp_states
    data = []
    @camp_state_mapping = {}
    CAMP_STATES.each_with_index do |s, i|
      labels_localized = locales.map {|loc|
        I18n.locale = loc
        ["label_#{loc}", I18n.t("activerecord.attributes.event/camp.states.#{s}")]
      }.to_h
      data.push({id: i, state: s}.merge(labels_localized))
      @camp_state_mapping[s] = i
    end
    return data
  end

  def locales
    @locales ||= [:de, :fr, :it]
  end

  def map_role(role_type)
    @role_mapping[role_type]
  end

  def map_group(group_type)
    @group_mapping[group_type]
  end

  def map_j_s_kind(j_s_kind)
    @j_s_kind_mapping[j_s_kind]
  end

  def map_camp_state(camp_state)
    @camp_state_mapping[camp_state]
  end

  def map_participation(participation_type)
    @participation_mapping[participation_type]
  end
end
