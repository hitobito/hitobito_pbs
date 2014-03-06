# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

CustomContent.seed_once(:key,
  {key: CensusMailer::CONTENT_REMINDER,
   placeholders_optional: 'recipient-names, due-date, contact-address, census-url'}
)

census_reminder_id = CustomContent.where(key: CensusMailer::CONTENT_REMINDER).first.id
CustomContent::Translation.seed_once(:custom_content_id, :locale,
  {custom_content_id: census_reminder_id,
   locale: 'de',
   label: 'Bestandesmeldung: E-Mail Erinnerung',
   subject: 'Bestandesmeldung ausfüllen!',
   body: "Hallo {recipient-names}<br/><br/>Wir bitten dich, den Bestand deiner Gruppe zu aktualisieren und die Bestandesmeldung bis am {due-date} zu bestätigen:<br/><br/>{census-url}<br/><br/>Vielen Dank für deine Mithilfe. Bei Fragen kannst du dich an die folgende Adresse wenden:<br/><br/>{contact-address}<br/><br/>Deine Pfadi"},

  {custom_content_id: census_reminder_id,
   locale: 'fr',
   label: 'Bestandesmeldung: E-Mail Erinnerung'},

  {custom_content_id: census_reminder_id,
   locale: 'en',
   label: 'Bestandesmeldung: E-Mail Erinnerung'},

  {custom_content_id: census_reminder_id,
   locale: 'it',
   label: 'Bestandesmeldung: E-Mail Erinnerung'},
)
