# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Exbank.Repo.insert!(%Exbank.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Exbank.{Banks, Repo}

Repo.insert!(%Banks.Bank{name: "teller", active: true})
