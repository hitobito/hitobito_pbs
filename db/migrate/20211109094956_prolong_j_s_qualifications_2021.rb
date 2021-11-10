#  Copyright (c) 2021, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class ProlongJSQualifications2021 < ActiveRecord::Migration[6.0]

  # prolongs a fixed list of J+S qualifications due to COVID-19.
  #
  # Alle J+S-Leiterinnen und -Leiter, welche 2019 zuletzt eine J+S-Ausbildung (z.B. Leiterkurs) oder ein
  # J+S-Weiterbildungsmodul besucht haben, bekommen ihre Einsatzberechtigung bis Ende 2022 verlängert («gültig bis 31.12.2022»).
  # Dies hat der Bundesrat am 30.6.2021 entschieden, weil viele Weiterbildungsmodule aufgrund der Coronamassnahmen nicht stattfinden konnten.
  # Source: https://www.jugendundsport.ch/de/corona/faq.html#ui-collapse-840
  # Nicht betroffen von dieser Massnahme sind J+S-Expertinnen und -Experten, J+S-Coaches sowie J+S-Leiterinnen und -Leiter,
  # welche letztmals 2018 oder früher in einer J+S-Aus- oder Weiterbildung absolviert haben.

  QUALIFICATION_KIND_LABELS =
    ['J+S Leiter LS/T Kindersport',
     'J+S Leiter LS/T Jugendsport'].freeze

  PROLONGED_DATE = Date.new(2022, 12, 31).freeze

  def up
    js_quali_courses_2021.find_each do |c|
      participant_ids = c.participations.collect(&:person_id)
      qualis = Qualification.where(person_id: participant_ids,
                                   qualification_kind_id:
                                   qualification_kind_ids,
                                   start_at: c.qualification_date)
      qualis.update_all(finish_at: PROLONGED_DATE)
    end
  end

  private

  def js_quali_courses_2021
    Event::Course
      .joins(:dates)
      .joins(:kind)
      .includes(:participations)
      .between(Date.new(2019, 1, 1), Date.new(2019, 12, 31))
      .where(event_kinds: { id: js_event_kind_ids })
  end

  def js_event_kind_ids
    Event::KindQualificationKind
      .where(qualification_kind_id: qualification_kind_ids)
      .pluck(:event_kind_id)
  end

  def qualification_kind_ids
    @qualification_kind_ids ||=
      QualificationKind
      .where(label: QUALIFICATION_KIND_LABELS)
      .pluck(:id)
  end

end
