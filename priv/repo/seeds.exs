# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     WeirdoLottery.Repo.insert!(%WeirdoLottery.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias WeirdoLottery.Repo

IO.puts("📍 Resetting the users table and populate 1M fresh users with 0 points. Stay tuned...")

Repo.query!("TRUNCATE users")

Repo.query!(
  "INSERT INTO users (inserted_at, updated_at) SELECT NOW(), NOW() FROM generate_series(1, 1e6)"
)

Repo.query!("VACUUM ANALYZE users")

IO.puts("🥳 Done.")
