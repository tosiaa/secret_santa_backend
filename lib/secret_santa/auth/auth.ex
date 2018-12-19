defmodule SecretSanta.Auth do
  import Ecto.Query, warn: false
  alias SecretSanta.Repo
  alias SecretSanta.User
  alias SecretSanta.Auth.Encryption

  def list_users do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def create_user(attrs \\ %{}) do
    user_changeset = User.registration_changeset(%User{}, attrs)
    result = Repo.insert(user_changeset)

    case result do
      {:ok, user} -> {:ok, %{user | password: nil}}
      _ -> result
    end
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def authenticate_user(login, plain_text_password) do
    user = Repo.get_by(User, login: login)

    case check_password(user, plain_text_password) do
      true -> {:ok, user}
      _ -> {:error, "Invalid login or password"}
    end
  end

  defp check_password(user, plain_text_password) do
    case user do
      nil -> Encryption.dummy_validate_password()
      _ -> Encryption.validate_password(plain_text_password, user.password_hash)
    end
  end
end
