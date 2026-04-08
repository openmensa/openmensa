# Meals

## List meals for a day {: #list }

```http
GET /canteens/{canteen_id}/days/{date}/meals HTTP/2.0
```

### Response

```http
HTTP/2.0 200 Ok
Content-Type: application/json; charset=utf-8

[
  {
    "id": 260,
    "name": "Gemüse-Couscouspfanne mit Joghurt-Ingwer-Dip, dazu bunter Blattsalat",
    "notes": [
      "ovo-lacto-vegetabil",
      "mensaVital"
    ],
    "prices": {
      "students": 2.3,
      "employees": 3.65,
      "others": 4.6
    },
    "category": "Alternativ-Angebot"
  },
  {
    "id": 10900,
    "name": "Hähnchenschnitzel mit Brötchen",
    "notes": [

    ],
    "prices": {
      "pupils": 2.4,
      "others": 4.3
    },
    "category": "Cafeteria Heiße Theke"
  }
]
```

## Get a meal {: #get }

```http
GET /canteens/{canteen_id}/days/{date}/meals/{id} HTTP/2.0
```

### Response {: #get-response }

```http
HTTP/2.0 200 Ok
Content-Type: application/json; charset=utf-8

{
  "id": 260,
  "name": "Gemüse-Couscouspfanne mit Joghurt-Ingwer-Dip, dazu bunter Blattsalat",
  "notes": [
    "ovo-lacto-vegetabil",
    "mensaVital"
  ],
  "prices": {
    "students": 2.3,
    "employees": 3.65,
    "others": 4.6
  },
  "category": "Alternativ-Angebot"
}
```
