$ = jQuery

old_update_state = update_state
update_state = (region, done)->
  old_update_state region, done
  if $.fn.select2?
    delay = -> $('span#' + region + 'state select.select2').select2 'destroy'
    setTimeout delay 500

$ ->
  return unless $.fn.select2?
  for region in ['b', 's']
    $("span##{region}state select.select2").select2('destroy').addClass 'form-control'
