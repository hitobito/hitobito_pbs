#  Copyright (c) 2012-2017, Dachverband Schweizer Jugendparlamente. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

app = window.App ||= {}

class app.MailingListLabels

  constructor: (@selector) ->
    @bind('click', 'a.chip-add', @show)
    @bind('click', 'span.chip .icon-remove', @remove)
    @bind('blur', 'input[name=label]', @update)
    @bind('keydown', 'input[name=label]', @preventEnterSubmit)

  show: (e) =>
    e.preventDefault()
    $("#{@selector} .chip-add").hide()
    $("#{@selector} input[name=label]").show().focus()

  hide: =>
    $("#{@selector} .chip-add").show()
    $("#{@selector} input[name=label]").hide()

  remove: (e) ->
    e.preventDefault()
    $(this).closest('.chip').remove()

  update: (e)=>
    label = $("#{@selector} input[name=label]")
    label.attr('name', 'mailing_list[preferred_labels][]')
    $.ajax(url: window.location.href + "?#{$(@selector).serialize()}", dataType: 'script')

  preventEnterSubmit: (event) =>
    if event.keyCode == 13
      event.stopPropagation()
      event.preventDefault()
      @update()

  bind: (event, selector, method)->
    $(document).on(event, "#{@selector} #{selector}", method)

new app.MailingListLabels('form[data-mailing-list-labels]')
