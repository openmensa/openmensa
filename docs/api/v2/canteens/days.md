# Days

## List days of a canteen {: #list }

```http
GET /api/v2/canteens/{canteen_id}/days HTTP/2.0
```

### Parameters {: #list-params }

`start` _YYYY-MM-DD_
:   Optional start date for listing available days. Defaults to current day if no nothing is specified.

!!! warning

    Canteens may not return have data for every day. If there is no data, closing information, or other details for a day, that day will not be listed.

### Response {: #list-response }

```http
HTTP/2.0 200 Ok
Content-Type: application/json; charset=utf-8

[
  {
    "date": "2012-10-12",
    "closed": false
  },
  {
    "date": "2012-10-15",
    "closed": true
  }
]
```

## Get a day {: #get }

```http
GET /canteens/{canteen_id}/days/{date} HTTP/2.0
```

### Response {: #get-response }

```http
HTTP/2.0 200 Ok
Content-Type: application/json; charset=utf-8

{
  "date": "2012-10-12",
  "closed": false
}
```
