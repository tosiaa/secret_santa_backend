defmodule SecretSanta.Circle do
  use Ecto.Schema
  import Ecto.Changeset
  alias SecretSanta.UserCircle
  alias __MODULE__
  
  schema "circles" do
    field :name, :string, null: false
    field :secret, :string, null: false
    field :is_open, :boolean, default: false
    has_many :user_circles, UserCircle

    timestamps()
  end

  def allowed_attrs(), do: [
    :name,
    :secret,
    :is_open
  ]

  def required_attrs(), do: [
    :name,
    :secret
  ]

  def changeset(%Circle{} = circle, attrs) do
    circle
      |> cast(attrs, allowed_attrs())
      |> validate_required(required_attrs())
  end
end
