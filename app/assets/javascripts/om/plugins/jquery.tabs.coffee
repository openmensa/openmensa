#
# tabs
#

$.fn.tabTarget = ->
  el = $ this
  if el.data 'tab-target'
    return $ el.data('tab-target')
  if el.attr('href') and el.attr('href')[0] == '#'
    return $ el.attr('href')
  null

$.fn._updateTabTargetVisibility = ->
  el = $ this
  if el.hasClass('active')
    el.tabTarget()?.show()
  else
    el.tabTarget()?.hide()

$.fn.tabs = ->
  $(this).each ->
    el = $ this
    li = el.closest 'li'
    el.bind 'click', (e) ->
      e.preventDefault()
      li.parent().children('li').each ->
        $(this).removeClass('active').find('[data-tab-target]').tabTarget()?.hide()
      li.addClass('active')
      el.tabTarget()?.show()
    if li.hasClass('active')
      el.tabTarget()?.show()
    else
      el.tabTarget()?.hide()
