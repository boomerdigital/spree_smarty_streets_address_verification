$ = jQuery

old_update_state = update_state
update_state = (region, done)->
  old_update_state region, done
  delay = -> $('span#' + region + 'state select.select2').select2 'destroy'
  setTimeout delay 500

$ ->
  for region in ['b', 's']
    $("span##{region}state select.select2").select2('destroy').addClass 'form-control'
