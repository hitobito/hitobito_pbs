# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require Rails.root.join('db', 'seeds', 'support', 'event_seeder')

srand(42)

class PbsEventSeeder < EventSeeder

  def seed_event(group_id, type)
    values = event_values(group_id)
    case type
      when :course then seed_course(values)
      when :camp then seed_camp(values)
      when :base then seed_base_event(values)
    end
  end

  def seed_course(values)
    event = super(values.merge(Hash[approvals]))
    event.reload
    event.state = Event::Course.possible_states.shuffle.first
    event.save!
  end

  def seed_camp(values)
    event = Event::Camp.seed(:name, camp_attributes(values)).first

    seed_dates(event, values[:application_opening_at] + 90.days)
    seed_questions(event)
    seed_leaders(event)
    seed_participants(event)

    event
  end

  def approvals
    count = rand(Event::Course::APPROVALS.size + 1)
    Event::Course::APPROVALS.sample(count).map do |attr|
      [attr, true]
    end
  end

  def camp_group_types
    Group.subclasses.select { |type| type.event_types.include?(Event::Camp) }
  end

  def camp_group_ids
    Group.where(type: camp_group_types).pluck(:id)
  end

  def camp_attributes(values)
    kind = @@kinds.shuffle.first
    values.merge(name: "#{kind.try(:short_name)} #{values[:number]}".strip,
                 kind_id: kind.try(:id),
                 state: Event::Camp.possible_states.shuffle.first,
                 signature: Event::Camp.used_attributes.include?(:signature),
                 external_applications: Event::Camp.used_attributes.include?(:external_applications))
  end
end


seeder = PbsEventSeeder.new

layer_types = Group.all_types.select(&:layer).collect(&:sti_name)
Group.where(type: layer_types).pluck(:id).each do |group_id|
  5.times do
    seeder.seed_event(group_id, :base)
  end
end

seeder.course_group_ids.each do |group_id|
  3.times do
    seeder.seed_event(group_id, :course)
  end
end

seeder.camp_group_ids.each do |group_id|
  3.times do
    seeder.seed_event(group_id, :camp)
  end
end

Event::Participation.update_all(state: 'assigned', active: true)
