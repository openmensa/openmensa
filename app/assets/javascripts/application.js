//
//= require jquery
//= require jquery_ujs
//= require rails-timeago
//= require locales/jquery.timeago.de.js
//= require leaflet
//= require leaflet.markercluster
//= require leaflet.control.locate
//= require leaflet.hash
//= require jquery.autocomplete

jQuery.timeago.settings.lang = "de";
jQuery.timeago.settings.allowFuture = true;


jQuery(function() {
  let tileLayer = L.tileLayer("https://openmensa.org/tiles/{z}/{x}/{y}.png", {
    attribution:
      'Map data &copy; <a href="https://openstreetmap.org">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
    maxZoom: 18,
  });

  $('[data-map="map"').each(function () {
    let map = L.map(this, { maxZoom: 18 });
    L.control.locate().addTo(map);
    map.addLayer(tileLayer);

    let cluster = new L.MarkerClusterGroup({
      showCoverageOnHover: false,
      maxClusterRadius: 40,
    });

    const markers = $(this).data("markers");
    if (Array.isArray(markers)) {
      for (const m of markers) {
        if (m.lat == null || m.lng == null || isNaN(m.lat) || isNaN(m.lng)) {
          continue;
        }

        marker = L.marker([m.lat, m.lng], { title: m.title });
        if (m.url != null) {
          marker.bindPopup(
            `<a class=\"popup-link\" href=\"${m.url}\">${m.title}</a><br />`
          );
        }

        cluster.addLayer(marker);
      }

      map.fitBounds(cluster.getBounds());
    } else {
      map.setView([52.39392162228438, 13.132932186126707], 18);
    }

    map.addLayer(cluster);

    if (map.getZoom() > 16) {
      map.setZoom(16);
    }

    if ($(this).data("hash")) {
      return new L.Hash(map);
    } else {
      return map;
    }
  });

  $('[data-map="interactive"]').each(function () {
    var lat, lng, map, marker;
    map = L.map(this, {
      scrollWheelZoom: true,
    });
    map.addLayer(tileLayer);
    lat = $($(this).data("lat"));
    lng = $($(this).data("lng"));
    marker = L.marker([lat.attr("value") || 0, lng.attr("value") || 0], {
      draggable: true,
    });
    marker.on("drag dragend", function (marker) {
      lat.attr("value", marker.target.getLatLng().lat);
      lng.attr("value", marker.target.getLatLng().lng);
    });
    map.addLayer(marker);
    map.setView([lat.attr("value"), lng.attr("value")], 17);
  });

  $(".alert a[data-dismiss]").each(function () {
    const el = $(this);
    el.on("click", function () {
      return el.parent().fadeOut();
    });
  });

  $(".alert a[data-auto-dismiss]").each(function () {
    const el = $(this);
    let timeout = parseInt(el.data("auto-dismiss"), 10);

    if (!(timeout != null && !isNaN(timeout))) {
      timeout = 4000;
    }

    setTimeout(function () {
      return el.parent().fadeOut();
    }, timeout);
  });

  $("[data-autocomplete]").each(function () {
    const el = $(this);
    el.autocomplete({
      lookup: el.data("autocomplete"),
      maxHeight: 150,
    });
  });
});

