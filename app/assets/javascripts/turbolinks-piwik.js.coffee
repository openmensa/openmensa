$(document).on 'page:change', ->
  if window._paq?
    _paq.push ['trackPageview']
  else if window.piwikTracker?
    piwikTracker.trackPageview()
