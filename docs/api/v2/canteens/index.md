# Canteens API

The Canteens API allows to query for all canteens or a geographical filtered subset. Canteens are supposed to not change very often and should be cached locally.

## List canteens {: #list }

List all canteens:

```http
GET /api/v2/canteens
```

### Parameters {: #list-params }

`near[lat]`, `near[lng]`
:   _Optional_ set of coordinates to search for canteens near the given location. Both coordinates must be specified and be valid floating point numbers.

    Example:

    ```http
    GET /api/v2/canteens?near[lat]=52.393535&near[lng]=13.127814
    ```

`near[dist]`
:   _Optional_ distance in kilometers to search near given coordinates. Requires coordinates to be specified too. Defaults to 10 kilometers.
    Example:

    ```http
    GET /api/v2/canteens?near[lat]=52.393535&near[lng]=13.127814&near[dist]=5
    ```

`ids`
:   _Optional_ list of comma-separated canteen IDs that should be returned.

`hasCoordinates`
:   _Optional_ restriction to only returned canteens with (`true`) or without (`false`) coordinates.

### Response {: #list-response }

```http
HTTP/2.0 200 Ok
Link: <https://openmensa.org/api/v2/canteens?page=2>; rel="next",
      <https://openmensa.org/api/v2/canteens?page=5>; rel="last"
Content-Type: application/json; charset=utf-8

[
  {
    "id": 1,
    "name": "Mensa UniCampus Magdeburg",
    "city": "Magdeburg",
    "address": "Pfälzer Str. 1, 39106 Magdeburg",
    "coordinates": null
  },
  {
    "id": 104,
    "name": "Bistro Tasty Studio Babelsberg",
    "city": "Potsdam",
    "address": "August-Bebel-Str. 26-53, 14482 Potsdam, Deutschland",
    "coordinates": [
      52.3877669669544,
      13.1209909915924
    ]
  }
]
```

## Get a canteen {: #get }

```http
GET /api/v2/canteens/{id} HTTP/2.0
```

### Response {: #get-response }

```http title="GET /api/v2/canteens/1"
HTTP/2.0 200 Ok
Content-Type: application/json; charset=utf-8

{
  "id": 1,
  "name": "Mensa UniCampus Magdeburg",
  "city": "Magdeburg",
  "address": "Pfälzer Str. 1, 39106 Magdeburg",
  "coordinates": [
    52.139618827301895,
    11.647599935531616
  ]
}
```

`id` _int_
:   Unique numerical identifier in the API and database

`name`
:   The canteens name

`address`
:   Human readable real-world locator (vulgo _street address_)

`coordinates`
:   Optional list of latitude and longitude in north-eastern direction. Negative values imply southern or western hemisphere. Can be `null` if no coordinates were given or they are unknown.
