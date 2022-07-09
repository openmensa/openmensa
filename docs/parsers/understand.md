# Concept

This document describes what you should know about task, terminology and usage of OpenMensa's parsers.

## Motivation

As described on the OpenMensa website OpenMensa is designed as information hub for canteen and its meal menus. The data parsers (canteen + menu) and the front ends (apps and other services) are community driven.

OpenMensa expects the menus to be provided as an OpenMensa Feed. Although the organization of canteens could provide this feed directly the most will not. So parsers are used to translate the data to the expected feed format.

Normally a organization runs multiple canteens at once (e.g. in the same city). So a parser can be used for multiple canteens.

## How OpenMensa Retrieves Canteen Menus (fetch)

For OpenMensa is a parser only an URL for a canteen. To update the canteen menus, OpenMensa performs a HTTP GET request to the given URL. The returned data must be an XML document that is valid against the [Feed v1](/feed/v1/) or [Feed v2](/feed/v2/). If OpenMensa receives a HTTP error or an invalid document, OpenMensa stops and the fetch is failed.

The provided parser URL should return all menu information available. Because this can be very costly, OpenMensa fetches this feed only once a day. To be able to get menu updates faster, OpenMensa supports so called today URLs. If provided, OpenMensa fetches this URL hourly from 8:00 to 15:00. OpenMensa assumes that this feed includes at least the menu for today (that's why it's named "today URL") but it can be more. Normal and today URL can be the same.

The following algorithm illustrates the OpenMensa behavior:

```python
def fetch_single_canteen(canteen): # called for every canteen at midnight
    sleep(8*3600); # start at 8 am to fetch
    # on every day start with main fetch, retry hourly on errors:
    successfully_fetch = False
    while not successfully_fetch:
        successfully_fetch = fetch_feed(canteen.main_url)
        sleep(3600)
    # if today URL provides, look hourly for updates:
    while canteen.today_url and now().hour < 15:
        fetch_feed(canteen.today_url)()
        sleep(3600)
```

## The Canteen Owner

All canteen data is community provided. Every canteen feed has an owner. This is the user who wrote the parser for this canteen, provided the canteen meta data and added it to OpenMensa. He can update all this data (canteen meta data, parser URL), and has also the possibility to instruct OpenMensa to do an extra fetch.

Additional the owner will be informed about all occurred fetch errors.
