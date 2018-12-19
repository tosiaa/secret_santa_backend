defmodule SecretSanta.UserCircle do
  use Ecto.Schema
  import Ecto.Changeset

  alias SecretSanta.User
  alias SecretSanta.Circle
  alias SecretSanta.Lottery
  alias __MODULE__
  
  @default_privileges %{
    "add_users" => false,
    "remove_users" => false,
    "add_lotteries" => false
  }

  schema "users_circles" do
    belongs_to :user, User
    belongs_to :circle, Circle
    field :privileges, :map, default: @default_privileges
  end


  def allowed_attrs(), do: [
    :privileges,
    :user_id,
    :circle_id
  ]

  def changeset(%UserCircle{} = user_circle, attrs) do
    user_circle
    |> cast(attrs, allowed_attrs())
  end
end
