# Overview

This describes the resources that make up the first public OpenMensa API v2.

## Schema

All API access happens over HTTPS.

Endpoint: `https://openmensa.org/api/v2`

All paths referenced throughout this document are meant to be relative to the API endpoint above.

## Formats

All data is sent and received as JSON by default.

### Encoding

Encoding for all requests and responses should be UTF-8.

### Date and Time

All timestamps are returned in ISO 8601 format (UTC).

```text
YYYY-MM-DDTHH:MM:SSZ
```

Dates will be returned without time information.

```text
YYYY-MM-DD
```

### Addresses

Postal address formats vary by country but at least the following information should be included in given order.

```text
street address, postal code + city/town, country
```

### Coordinates

Geographic coordinates are returned as an array of latitude and longitude.

```json
[
  52.3877669669544,
  13.1209909915924
]
```

## Examples

All examples are given in JSON notion (request as well as response bodies), for general rules how the XML will look see [here](/api/v2/xml/).

Unless otherwise stated a response will contain all shown fields.

## Pagination

Requests returning multiple items will be paginated to **10** items by default. You can specify the number of items per page using the `limit` parameter. Allowed values are between 1 and 100. The upper limit may be different for specific resources.

Further pages can be requested by specifying the `page` parameter. First page
(the one you usually retrieve without explicitly specifying the page number)
is page number **1**.

## Client Errors

See [here](errors.md).
