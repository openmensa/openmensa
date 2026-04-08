# Overview

This describes the resources that make up the first public OpenMensa API v2.

## Schema

Primary API Endpoint
:   `https://openmensa.org/api/v2`

All API access has to happen over HTTPS. All paths in this documentation are meant to be relative to this API endpoint.

## Formats

All data is sent and received as JSON by default.

### Encoding

Encoding for all requests and responses should be UTF-8.

### Date and Time

All timestamps are formatted as ISO 8601 format and in UTC.

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

All examples are given in JSON notion (request and responses).

Unless otherwise stated a response will contain all shown fields.

## Pagination

Requests returning multiple items will be paginated to **10** items by default. You can specify the number of items per page using the `limit` parameter. Allowed values are between 1 and 100. The upper limit may be different for specific resources.

Following pages can be requested by specifying the `page` parameter. The first page has the number **1**, and is returned by default if no query parameter is specified.
