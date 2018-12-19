defmodule SecretSanta.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias SecretSanta.Auth.Encryption
  alias SecretSanta.UserCircle
  alias __MODULE__


  schema "users" do
    field :login, :string
    field :name, :string
    field :wishes, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    has_many :users_circles, UserCircle
    timestamps()
  end

  def allowed_attrs(), do: [
    :login,
    :name,
    :wishes,
  ]

  def required_attrs(), do: [
    :login,
    :name
  ]

  def attrs_for_view(), do: allowed_attrs() ++ [:id, :inserted_at,:updated_at]

  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, allowed_attrs())
    |> validate_required(required_attrs())
    |> validate_length(:login, min: 3, max: 255)
    |> unique_constraint(:login)
  end

  def registration_changeset(%User{} = user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 100)
    |> put_password_hash()
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password_hash: Encryption.password_hashing(password))
  end
  defp put_password_hash(changeset), do: changeset
end
