# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     SecretSanta.Repo.insert!(%SecretSanta.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

{:ok, _} = SecretSanta.Auth.create_user(%{
  name: "Miron",
  login: "majronman",
  password: "Secret123",
  wishes: "For this sorrow to end"
})

