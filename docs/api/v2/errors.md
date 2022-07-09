# Client Errors

## 400 Bad Request

For example, when sending invalid JSON/XML/MessagePack data in request body:

```http
HTTP/2.0 400 Bad Request
```

## 404 Not Found

Accessing a non-existing resource:

```http
HTTP/2.0 404 Not Found
```

## 422 Unprocessable Entity

Possible reasons:

* Sending invalid fields or invalid field content in request body, or
* Sending invalid parameters or invalid parameter content in URL parameters.

```http
HTTP/2.0 422 Unprocessable Entity
```
