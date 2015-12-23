-#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
-#  hitobito_pbs and licensed under the Affero General Public License version 3
-#  or later. See the COPYING file at the top-level directory or at
-#  https://github.com/hitobito/hitobito_pbs.

updateLocalScoutContactFieldsVisibility = ->
  canton_field = $('select#event_canton')
  if canton_field.length
    local_scout_fields = $('#event_local_scout_contact_present, #event_local_scout_contact')
    if local_scout_fields.length
      if canton_field.val() == 'zz'
        local_scout_fields.closest('.control-group').show()
      else
        local_scout_fields.closest('.control-group').hide()

$(document).on('change', 'select#event_canton', updateLocalScoutContactFieldsVisibility)

$ ->
  updateLocalScoutContactFieldsVisibility()
