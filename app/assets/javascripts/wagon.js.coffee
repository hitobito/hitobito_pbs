-#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
-#  hitobito_pbs and licensed under the Affero General Public License version 3
-#  or later. See the COPYING file at the top-level directory or at
-#  https://github.com/hitobito/hitobito_pbs.

# Show fields regarding local scout contact depending on canton selection
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

# Show help text depending on canton selection
updateCantonSpecificHelpTextVisibility = (event) ->
  canton_short_name = event && event.target.value
  $('.canton-specific-help-texts .help-block').hide()
  $('.canton-specific-help-texts .help-block#' + canton_short_name).show()
$(document).on('change', 'select#event_canton', updateCantonSpecificHelpTextVisibility)

# On document load, run all visibility updates once
$(document).on 'turbolinks:load', ->
  updateLocalScoutContactFieldsVisibility()
  updateCantonSpecificHelpTextVisibility()

removeSupercamp = ->
  $('#event_parent_id').val(null)
  console.log($(this), $(this).closest('.control-group'))
  $(this).closest('.control-group').hide()

$(document).on('turbolinks:load', ->
  $('[data-remove-supercamp]').click(removeSupercamp)
)
