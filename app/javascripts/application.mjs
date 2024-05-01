//

import Rails from "@rails/ujs";
Rails.start();

import "jquery.autocomplete";

import L from "leaflet";
import "leaflet-hash";
import "leaflet.locatecontrol";
import "leaflet.locatecontrol/dist/L.Control.Locate.min.css";
import "leaflet.markercluster";
import "leaflet/dist/leaflet.css";

import iconRetinaUrl from "leaflet/dist/images/marker-icon-2x.png";
import iconUrl from "leaflet/dist/images/marker-icon.png";
import shadowUrl from "leaflet/dist/images/marker-shadow.png";

// jQuery.timeago.settings.lang = "de";
// jQuery.timeago.settings.allowFuture = true;

Object.assign(L.Icon.Default.prototype.options, {
  iconUrl: iconUrl,
  iconRetinaUrl: iconRetinaUrl,
  shadowUrl: shadowUrl,
  shadowRetineUrl: shadowUrl,
});

$(() => {
  const tileLayer = L.tileLayer("https://openmensa.org/tiles/{z}/{x}/{y}.png", {
    attribution:
      'Map data &copy; <a href="https://openstreetmap.org">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
    maxZoom: 18,
  });

  $('[data-map="map"').each(function () {
    const map = L.map(this, { maxZoom: 18 });
    L.control.locate().addTo(map);
    map.addLayer(tileLayer);

    const cluster = new L.MarkerClusterGroup({
      showCoverageOnHover: false,
      maxClusterRadius: 45,
    });

    const markers = $(this).data("markers");
    if (Array.isArray(markers)) {
      for (const m of markers) {
        if (
          m.lat == null ||
          m.lng == null ||
          Number.isNaN(m.lat) ||
          Number.isNaN(m.lng)
        ) {
          continue;
        }

        const marker = L.marker([m.lat, m.lng], { title: m.title });
        if (m.url != null) {
          marker.bindPopup(
            `<a class=\"popup-link\" href=\"${m.url}\">${m.title}</a><br />`,
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
    }
    return map;
  });

  $('[data-map="interactive"]').each(function () {
    const map = L.map(this, {
      scrollWheelZoom: true,
    });
    map.addLayer(tileLayer);

    const lat = $($(this).data("lat"));
    const lng = $($(this).data("lng"));
    const marker = L.marker([lat.attr("value") || 0, lng.attr("value") || 0], {
      draggable: true,
    });

    marker.on("drag dragend", (marker) => {
      lat.attr("value", marker.target.getLatLng().lat);
      lng.attr("value", marker.target.getLatLng().lng);
    });

    map.addLayer(marker);
    map.setView([lat.attr("value"), lng.attr("value")], 17);
  });

  $(".alert a[data-dismiss]").each(function () {
    const el = $(this);
    el.on("click", () => el.parent().fadeOut());
  });

  $(".alert a[data-auto-dismiss]").each(function () {
    const el = $(this);
    let timeout = Number.parseInt(el.data("auto-dismiss"), 10);

    if (!(timeout != null && !Number.isNaN(timeout))) {
      timeout = 4000;
    }

    setTimeout(() => el.parent().fadeOut(), timeout);
  });

  $("[data-autocomplete]").each(function () {
    const el = $(this);
    el.autocomplete({
      lookup: el.data("autocomplete"),
      maxHeight: 150,
    });
  });
});
