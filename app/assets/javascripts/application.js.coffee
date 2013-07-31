#
#= require jquery
#= require jquery_ujs
#= require rails-timeago
#= require locales/jquery.timeago.de.js
#= require turbolinks
#= require turbolinks-piwik
#= require leaflet
#= require leaflet.markercluster
#= require leaflet.control.locate
#= require leaflet.hash

$ ->
  jQuery.timeago.settings.lang = 'de';

  $(document).bind 'page:change', ->
    tileLayer = L.tileLayer('//openmensa.org/tiles/{z}/{x}/{y}.png',
      attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
      maxZoom: 18)

    $('[data-map="map"]').each ->
      map = L.map(@, maxZoom: 18)
      L.control.locate().addTo(map);
      map.addLayer tileLayer

      cluster = new L.MarkerClusterGroup showCoverageOnHover: false
      markers = $(@).data("markers")
      markers = [] unless $.isArray markers
      for m in markers
        marker = L.marker([m.lat, m.lng], { title: m.title })
        marker.bindPopup "<a class=\"popup-link\" href=\"#{m.url}\">#{m.title}</a><br />" if m.url?
        cluster.addLayer marker
      map.addLayer cluster

      if markers.length > 0
        map.fitBounds new L.LatLngBounds(new L.LatLng(m.lat, m.lng) for m in markers)
      else
        map.setView([52.39392162228438, 13.132932186126707], 18)

      if map.getZoom() > 16
        map.setZoom 16

      if $(@).data('hash')
        new L.Hash map
      else
        map

    $('[data-map="interactive"]').each ->
      map = L.map(@, scrollWheelZoom: true)
      map.addLayer tileLayer

      lat = $ $(@).data("lat")
      lng = $ $(@).data("lng")

      marker = L.marker [lat.attr('value'), lng.attr('value')], { draggable: true }
      marker.on "drag dragend", (marker) ->
        lat.attr 'value', marker.target.getLatLng().lat
        lng.attr 'value', marker.target.getLatLng().lng

      map.addLayer marker
      map.setView [lat.attr('value'), lng.attr('value')], 17

    $('.alert a[data-dismiss]').each ->
      el = $ @
      el.bind 'click', (e) ->
        el.parent().fadeOut()

    $('.alert a[data-auto-dismiss]').each ->
      el = $ @
      timeout = parseInt el.data('auto-dismiss'), 10
      timeout = 4000 unless timeout? and !isNaN(timeout)
      setTimeout ->
        el.parent().fadeOut()
      , timeout
  $(document).trigger 'page:change'
