# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Pbs::Event::Constraints
  extend ActiveSupport::Concern

  included do
    alias_method_chain :in_same_group, :excluded_abteilungen_for_courses
    alias_method_chain :in_same_group_or_below, :excluded_abteilungen_for_courses
    alias_method_chain :in_same_layer, :excluded_abteilungen_for_courses
    alias_method_chain :in_same_layer_or_below, :excluded_abteilungen_for_courses
  end

  def in_same_group_with_excluded_abteilungen_for_courses
    !course_in_abteilung? && in_same_group_without_excluded_abteilungen_for_courses
  end

  def in_same_group_or_below_with_excluded_abteilungen_for_courses
    !course_in_abteilung? && in_same_group_or_below_without_excluded_abteilungen_for_courses
  end

  def in_same_layer_with_excluded_abteilungen_for_courses
    !course_in_abteilung? && in_same_layer_without_excluded_abteilungen_for_courses
  end

  def in_same_layer_or_below_with_excluded_abteilungen_for_courses
    in_same_layer ||
    permission_in_layers?(course_group_ids_above_abteilung)
  end

  def in_same_layer_or_course_in_below_abteilung
    in_same_layer ||
      (course_in_abteilung? &&
        permission_in_layers?(course_group_ids_above_abteilung - [Group.root.id]))
  end

  private

  # people in abteilungen are generally not allowed to edit anything related to courses.
  def course_in_abteilung?
    event.is_a?(Event::Course) &&
    event.groups.any? { |g| g.is_a?(Group::Abteilung) }
  end

  def course_group_ids_above_abteilung
    event.groups.collect do |g|
      hierarchy = g.layer_hierarchy
      hierarchy.pop if g.is_a?(Group::Abteilung)
      hierarchy
    end.flatten.collect(&:id).uniq
  end
end
