# WeirdoLottery

Welcome to the weirdo lottery. At the moment we have 1M participants, all of them have a lottery ticket with [0, 100] points. There's also a lottery minion who helps with the drawing and - because he's a minion - randomizes the points of all participants and the points threshold to win every minute. 

You can send the minion to draw up to 2 winners anytime by visiting [`localhost:3000/`](http://localhost:3000/) in your browser or in the console via `curl http://localhost:3000/ -H "Accept: application/json"`.

```
GET / HTTP/1.1

HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8

{
  "timestamp": "2022-03-20 14:09:20Z",
  "users": [
    {
      "id": 16560343,
      "points": 100
    },
    {
      "id": 16033326,
      "points": 48
    }
  ]
}
```
The `timestamp` (UTC) is the timestamp of the previous lottery drawing.

## Start the app
  * Install dependencies with `mix deps.get`
  * Copy `database.dev.exs.sample` to `database.dev.exs` and config your dev PostgreSQL DB
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`


## Run tests
  * Copy `database.test.exs.sample` to `database.test.exs` and config your test PostgreSQL DB

Run the test suite with `mix test`.