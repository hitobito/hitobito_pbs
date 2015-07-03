# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito_jubla and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_jubla.

quali_kinds = QualificationKind.seed(:id,
 {id: 1,
  validity: nil},

 {id: 2,
  validity: 2, reactivateable: 4},

 {id: 3,
  validity: 2, reactivateable: 4},

 {id: 4,
  validity: 4, reactivateable: 4},
)

QualificationKind::Translation.seed(:qualification_kind_id, :locale,
  {qualification_kind_id: quali_kinds[0].id,
   locale: 'de',
   label: 'Absolvent Leitpfadikurs'},

  {qualification_kind_id: quali_kinds[1].id,
   locale: 'de',
   label: 'J+S Leiter LS/T Kindersport'},

  {qualification_kind_id: quali_kinds[2].id,
   locale: 'de',
   label: 'J+S Leiter LS/T Jungendsport'},

  {qualification_kind_id: quali_kinds[3].id,
   locale: 'de',
   label: 'SLRG Brevet Basis Pool'},
)

event_kinds = Event::Kind.seed(:id,
 {id: 1,
  minimum_age: 13, bsv_id: '1' },

 {id: 2,
  minimum_age: 17, bsv_id: '2' },

 {id: 3,
  minimum_age: 17, bsv_id: '3' },

 {id: 4},
)

Event::Kind::Translation.seed(:event_kind_id, :locale,
  {event_kind_id: event_kinds[0].id,
   locale: 'de',
   label: 'Leitpfadikurs',
   short_name: 'LPK'},

  {event_kind_id: event_kinds[1].id,
   locale: 'de',
   label: 'Basiskurs Wolfstufe',
   short_name: 'BKWS'},

  {event_kind_id: event_kinds[2].id,
   locale: 'de',
   label: 'Basiskurs Pfadistufe',
   short_name: 'BKPS'},

  {event_kind_id: event_kinds[3].id,
   locale: 'de',
   label: 'Sicherheitsmodul Wasser',
   short_name: 'SMW'},
)

Event::KindQualificationKind.seed(:id,
  {id: 1,
   event_kind_id: event_kinds[0].id,
   qualification_kind_id: quali_kinds[0].id,
   category: :qualification,
   role: :participant},

  {id: 2,
   event_kind_id: event_kinds[1].id,
   qualification_kind_id: quali_kinds[1].id,
   category: :qualification,
   role: :participant},

  {id: 3,
   event_kind_id: event_kinds[1].id,
   qualification_kind_id: quali_kinds[1].id,
   category: :prolongation,
   role: :leader},

  {id: 4,
   event_kind_id: event_kinds[1].id,
   qualification_kind_id: quali_kinds[2].id,
   category: :prolongation,
   role: :leader},

  {id: 5,
   event_kind_id: event_kinds[2].id,
   qualification_kind_id: quali_kinds[2].id,
   category: :qualification,
   role: :participant},

  {id: 6,
   event_kind_id: event_kinds[2].id,
   qualification_kind_id: quali_kinds[1].id,
   category: :prolongation,
   role: :leader},

  {id: 6,
   event_kind_id: event_kinds[2].id,
   qualification_kind_id: quali_kinds[2].id,
   category: :prolongation,
   role: :leader},
)
