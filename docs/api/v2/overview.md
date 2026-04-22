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

## Pagination

Listing resources usually returns multiple items, grouped in pages. Accessing an endpoint without parameters returns the first page.

Related pages, for example, the next or previous page is specified in the `Link` header, as the `next` or `prev` relation, if there is such a page. Additionally, the `first` or `last` page _can_ be linked too.

!!! example

    Requesting the first page of `/api/v2/canteens`:

    ```http
    HTTP/2.0 200 Ok
    Link: <https://openmensa.org/api/v2/canteens?page=2>; rel="next",
          <https://openmensa.org/api/v2/canteens?page=3>; rel="last"
    X-Total-Pages: 3
    X-Total-Count: 1297
    X-Per-Page: 500
    X-Current-Page: 1
    Content-Type: application/json; charset=utf-8

    { ... }
    ```

To iterate over all pages, fetch the first page and follow the `next` relation until there is none. This is the safest way, because even changes the pagination won't break the client code.

!!! example

    ```ruby
    url = "https://openmensa.org/api/v2/canteens"

    loop do
      response = get(url)

      # Do something with the response data

      # Stop if there is no `next` relation in the Link header;
      # all pages have been fetched
      break unless response.rel?("next")

      # Use the URL from `next` link to get the next page
      url = response.rel("next")
    end
    ```

Not all resources might have a numeric page. Therefore, manually requesting pages by setting `?page=` is not recommended.

### Per-Page Item Count

A lower or higher per-page item count can be requested, by setting the `?per_page=` query parameter.

Each resource has an upper cap for the per-page item count. If the given limit is larger, the count will be capped.

### Informative Headers

Response can include some informative headers, but not all resources might provide all:

`X-Total-Count`
:   Total number of resources.

`X-Total-Pages`
:   Total number of pages.

`X-Per-Page`
:   Number of items per page.

`X-Current-Page`
:   The current page number.

### Non-numerical Pagination

Some resources might not have a numerical page, but a different
identifier for the next page. In this case, the `next` relation in the
`Link` header will include the URL for the next page, but there won't be
all informative headers.

That is because numerical pagination requires chunking all items into pages, which can be expensive for some resources. These might instead use a cursor, to fetch the items for the next page, which is more efficient.

## Examples

All examples are given in JSON notion (request and responses).

Unless otherwise stated a response will contain all shown fields.
