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
    when :base then seed_base_event(values)
    end
  end

  def seed_course(values)
    event = super(values.merge(Hash[approvals]))
    event.reload
    event.state = Event::Course.possible_states.shuffle.first
    event.save!
  end

  def approvals
    count = rand(Event::Course::APPROVALS.size + 1)
    Event::Course::APPROVALS.sample(count).map do |attr|
      [attr, true]
    end
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

Event::Participation.update_all(state: 'assigned', active: true)
