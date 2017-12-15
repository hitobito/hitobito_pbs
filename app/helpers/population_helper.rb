# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module PopulationHelper

  BADGE_INVALID = '<span class="text-error">Angabe fehlt</span>'.html_safe

  def person_gender_with_check(person)
    if person.gender.blank?
      BADGE_INVALID
    else
      person.gender_label
    end
  end

  def tab_population_label(group)
    label = t('groups.tabs.population')
    label << ' <span style="color: red;">!</span>' if check_approveable?(group)
    label.html_safe
  end

  def check_approveable?(group = @group)
    group.population_approveable? && can?(:create_member_counts, group)
  end

  def age(year)
    return '-' if year.nil?
    age = Time.zone.now.year - year
    if age < 0
      '-'
    else
      age
    end
  end

end
