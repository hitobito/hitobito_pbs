# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Event::TentativesController < ApplicationController

  helper_method :group, :entry, :model_class, :entry
  before_filter :load_group_and_event

  decorates :event, :group

  def index
    authorize!(:list_tentatives, @event)

    @counts = @event.
      participations.
      tentative.
      joins(person: :primary_group).
      joins('LEFT OUTER JOIN groups layer_groups on groups.layer_group_id = layer_groups.id').
      group('layer_groups.id', 'layer_groups.name').
      order('layer_groups.id desc').
      count
  end

  def new
    authorize!(:create_tentative, build)
  end

  def create
    authorize!(:create_tentative, build_for_person)

    if @participation.save
      flash[:notice] = t('event.tentatives.created', participant: @participation.person)
      redirect_to group_event_path(@group, @event)
    else
      render :new
    end
  end

  def query
    authorize!(:query, Person)
    people = []

    if params.key?(:q) && params[:q].size >= 3
      people = Person.where(search_condition(*PeopleController::QUERY_FIELDS)).
        includes(roles: :group).
        only_public_data.
        order_by_name.
        accessible_by(PersonWritables.new(current_user)).
        limit(10).decorate
    end

    render json: people.collect(&:as_typeahead)

  end

  private

  def load_group_and_event
    @group = Group.find(params[:group_id])
    @event = Event::Course.find(params[:event_id])
  end

  def build
    @participation = @event.participations.new(state: 'tentative')
  end

  def build_for_person
    participation = @event.participations.new(state: 'tentative',
                                              person_id: params[:event_participation][:person_id])

    role = participation.roles.build(type: @event.class.participant_types.first.sti_name)
    role.participation = participation

    @participation = participation
  end

  # Compose the search condition with a basic SQL OR query, copied from lists_controller
  def search_condition(*columns)
    if columns.present? && params[:q].present?
      terms = params[:q].split(/\s+/).collect { |t| "%#{t}%" }
      clause = columns.collect do |f|
        col = f.to_s.include?('.') ? f : "people.#{f}"
        "#{col} LIKE ?"
      end.join(' OR ')
      clause = terms.collect { |_| "(#{clause})" }.join(' AND ')

      ["(#{clause})"] + terms.collect { |t| [t] * columns.size }.flatten
    end
  end

end
