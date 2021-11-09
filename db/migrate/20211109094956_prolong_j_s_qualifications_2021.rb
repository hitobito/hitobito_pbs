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
  def change
    finish_dates = ['2020-12-31', '2019-12-31', '2018-12-31']
    qualification_kinds = [
        'J+S Leiter LS/T Kindersport',
        'J+S Leiter LS/T Jugendsport'
    ]
    qualification_kind_ids = QualificationKind
                                 .where(label: qualification_kinds)
                                 .pluck(:id)
    # Qualification
        # .where(qualification_kind: qualification_kind_ids, finish_at: finish_dates)
        # .update_all(finish_at: '2021-12-31')
  end
end
