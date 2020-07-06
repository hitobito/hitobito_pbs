#  Copyright (c) 2020, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class ProlongJSQualifications < ActiveRecord::Migration[6.0]

  # prolongs a fixed list of J+S qualifications due to COVID-19.
  #
  # "Die Einsatzberechtigung der J+S-Kader (J+S-Leiter/innen, J+S-Expert/innen, J+S-Coaches,
  # J+S-Coach-Expert/innen) wird ausserordentlich bis 31.12.2021 verlängert. Davon betroffen sind
  # alle Anerkennungen mit Status «weggefallen seit 01.01.2019», «weggefallen seit 01.01.2020» und
  # «gültig bis 31.12.2020». Alle diese Personen sind somit bis Ende 2021 einsatzberechtigt, auch
  # wenn sie kein Weiterbildungsmodul besucht haben. (Stand: 27. Mai 2020)"
  # Source: https://www.jugendundsport.ch/de/corona/faq.html#ui-collapse-298
  def change
    finish_dates = ['2020-12-31', '2019-12-31', '2018-12-31']
    qualification_kinds = [
        'J+S Leiter LS/T Kindersport',
        'J+S Leiter LS/T Jugendsport',
        'J+S Experte LS/T',
        'J+S Coach',
        'J+S Coach Experte'
    ]
    qualification_kind_ids = QualificationKind
                                 .where(label: qualification_kinds)
                                 .pluck(:id)
    Qualification
        .where(qualification_kind: qualification_kind_ids, finish_at: finish_dates)
        .update_all(finish_at: '2021-12-31')
  end

end
