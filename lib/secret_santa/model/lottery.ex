defmodule SecretSanta.Lottery do
  use Ecto.Schema
  import Ecto.Changeset
  alias SecretSanta.Auth.Encryption
  alias SecretSanta.User
  alias __MODULE__
  
  schema "lotteries" do
    belongs_to :circle, Circle
    field :pairing, :map, null: false
    field :deadline, :date, null: false
  end

  def allowed_attrs(), do: [
    :pairing,
    :deadline,
    :circle_id
  ]

  def required_attrs(), do: [
    :pairing,
    :deadline
  ]

  def changeset(%Lottery{} = lottery, attrs) do
    lottery
      |> cast(attrs, allowed_attrs())
      |> validate_required(attrs, required_attrs())
  end
end
