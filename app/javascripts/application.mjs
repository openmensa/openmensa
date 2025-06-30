//

import Rails from "@rails/ujs";
Rails.start();

import "jquery.autocomplete";

import L from "leaflet";
import "leaflet-hash";
import { LocateControl } from "leaflet.locatecontrol";
import "leaflet.locatecontrol/dist/L.Control.Locate.min.css";
import "leaflet.markercluster";
import "leaflet/dist/leaflet.css";

import iconRetinaUrl from "leaflet/dist/images/marker-icon-2x.png";
import iconUrl from "leaflet/dist/images/marker-icon.png";
import shadowUrl from "leaflet/dist/images/marker-shadow.png";

Object.assign(L.Icon.Default.prototype.options, {
  iconUrl: iconUrl,
  iconRetinaUrl: iconRetinaUrl,
  shadowUrl: shadowUrl,
  shadowRetineUrl: shadowUrl,
});

function toJSON(value) {
  try {
    return JSON.parse(value);
  } catch (error) {
    return null;
  }
}

function ready(fn) {
  if (document.readyState !== "loading") {
    fn();
  } else {
    document.addEventListener("DOMContentLoaded", fn);
  }
}

ready(() => {
  const tileLayer = L.tileLayer("https://openmensa.org/tiles/{z}/{x}/{y}.png", {
    attribution:
      'Map data &copy; <a href="https://openstreetmap.org">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
    maxZoom: 18,
  });

  document.querySelectorAll('[data-map="map"]').forEach((element) => {
    const map = L.map(element, { maxZoom: 18 });
    new LocateControl().addTo(map);
    map.addLayer(tileLayer);

    const cluster = new L.MarkerClusterGroup({
      showCoverageOnHover: false,
      maxClusterRadius: 45,
    });

    const markers = toJSON(element.dataset.markers);
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

    if (toJSON(element.dataset.hash)) {
      return new L.Hash(map);
    }
    return map;
  });

  document.querySelectorAll('[data-map="interactive"]').forEach((element) => {
    const map = L.map(element, { scrollWheelZoom: true });
    map.addLayer(tileLayer);

    const lat = $(element.dataset.lat);
    const lng = $(element.dataset.lng);
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
});

function fadeOut(el) {
  el.style.opacity = 1;
  el.style.transition = "opacity 1s";
  el.style.opacity = 0;

  setTimeout(() => el.remove(), 1000);
}

ready(() => {
  document.querySelectorAll(".alert a[data-dismiss]").forEach((element) => {
    element.addEventListener("click", (event) => {
      event.preventDefault();
      fadeOut(element);
    });
  });

  document
    .querySelectorAll(".alert a[data-auto-dismiss]")
    .forEach((element) => {
      let timeout = Number.parseInt(element.dataset.dismiss, 10);

      if (!(timeout != null && !Number.isNaN(timeout))) {
        timeout = 4000;
      }

      setTimeout(() => fadeOut(element), timeout);
    });

  $("[data-autocomplete]").each(function () {
    const el = $(this);
    el.autocomplete({
      lookup: el.data("autocomplete"),
      maxHeight: 150,
    });
  });
});
