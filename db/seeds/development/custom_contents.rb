# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

CustomContent.seed(:key,
  {key: 'views/devise/sessions/info',
   placeholders_required: nil,
   placeholders_optional: nil},
)

login_form_id = CustomContent.get('views/devise/sessions/info').id

CustomContent::Translation.seed(:custom_content_id, :locale,

  {custom_content_id: login_form_id,
   locale: 'de',
   label: 'Login Informationen',
   body: "<h2>Well done!</h2>\
<p>Du kannst dich mit den folgenden E-Mail-Adressen anmelden:</p>\
<ul>\
  <li>hitobito@example.com (Passwort: hito42bito) - Administrator mit vollem Zugriff</li>\
</ul\>"},

  {custom_content_id: login_form_id,
   locale: 'fr',
   label: 'Informations au login',
   body: "<h2>Bien fait!</h2>\
<p>Tu peux utiliser le suivant pour le login:</p>\
<ul>\
  <li>hitobito@example.com (Passwort: hito42bito) - Administratuer avec access complet</li>\
</ul\>"},

  {custom_content_id: login_form_id,
   locale: 'en',
   label: 'Login Information',
   body: "<h2>Ben cotto!</h2>\
<p>È possibile effettuare il login con i seguenti indirizzi e-mail:</p>\
<ul>\
  <li>hitobito@example.com (password: hito42bito) - amministratore con pieno accesso</li>\
</ul\>"}

)
