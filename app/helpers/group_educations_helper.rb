# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module GroupEducationsHelper

  def joined_qualification_kind_labels(person)
    person.qualifications.map do |qualification|
      qualification.qualification_kind.label
    end.join(', ')
  end

  def joined_event_participations(person)
    open_course_states = Event::Course.possible_states - %w(canceled completed closed)
    person.event_participations.select do |participation|
      participation.course? && open_course_states.include?(participation.event.state)
    end.collect { |p| format_open_participation_event(p) }.join(', ')
  end

  def format_open_participation_event(participation)
    event = participation.event
    if participation.tentative?
      link_to(event.name, [event.groups.first, event], style: 'padding-right: 0.5em') + badge('?', 'warning', t('.tentative_participation'))
    else
      link_to(event.name, [event.groups.first, event])
    end
  end

end
