$ = jQuery

$(document).on 'ready page:load', ->

  # Must decorate this method in the ready event as Spree doesn't create the
  # method until the ready event.
  old_fill_states = Spree.fillStates
  Spree.fillStates = (data, region) ->
    country_fld = $ "[id$='_#{if region == 'b' then 'bill' else 'ship'}_address_attributes_country_id']"
    us_address = $(country_fld).find('option:selected').text().match /united states/i

    state_fld = $ '#' + region + 'state select'
    smarty_disable state_fld[0], true unless us_address
    old_fill_states data, region

  # As the page loads tear down the problematic `select2` and make it a standard
  # control.
  return unless $.fn.select2?
  for region in ['b', 's']
    $("span##{region}state select.select2").select2('destroy').addClass 'form-control'

# If the state is updated we want to decorate two things onto the process:
#
# * The select2 that might be activated needs to be de-activated to make it
#   compatible with the SmartyStreets jQuery plugin. We did this on page load
#   but as the country is changed Spree will attempt to re-activate select2
# * We need to de-activate the validator as this means we are switching out
#   the state which the validator cannot handle.
old_update_state = window.update_state
window.update_state = (region, done)->
  state_fld = $ 'span#' + region + 'state select.select2'
  smarty_disable state_fld[0], true
  decorated_done = ->
    done() if done
    state_fld.select2 'destroy' if $.fn.select2?
  old_update_state region, decorated_done

# On the order page the user can disable shipping and instead using the billing
# for the shipping. When this happens we dont' want to do validation even if
# a US address. If we re-enable those field we want to notify smarty that it
# should work again.
$(document).on 'change', '#order_use_billing', ->
  address = $('#shipping input[id$="address1"]')[0]
  return unless address
  if $('#order_use_billing').is ':checked'
    smarty_disable address
  else
    smarty_enable address

# Ensure initial state is correct regarding smarty and the visibilty of
# shipping.
$(document).on 'ready page:load', ->
  delay = -> $('#order_use_billing').trigger 'change'
  setTimeout delay, 100

# The smarty street plugin keeps it's own model of the address it validates
# and does not read the fields. It has change events registered to keep the
# fields and it's model in sync. When spree updates the billing address fields
# it updates the value and does not send the change event. This means
# SmartyStreets does not see the new values entered. This patch sends that
# event so it Smarty Streets will update it's model.
$(document).on 'change', '#customer_search', ->
  $('input[id^="order_bill_address"]').trigger 'change'
