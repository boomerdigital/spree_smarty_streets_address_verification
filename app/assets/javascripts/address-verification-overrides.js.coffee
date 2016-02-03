$ = jQuery

old_update_state = window.update_state
window.update_state = (region, done)->
  decorated_done = ->
    $('span#' + region + 'state select.select2').select2 'destroy' if $.fn.select2?
    done() if done
  old_update_state region, decorated_done

$(document).on 'ready page:load', ->
  return unless $.fn.select2?
  for region in ['b', 's']
    $("span##{region}state select.select2").select2('destroy').addClass 'form-control'
