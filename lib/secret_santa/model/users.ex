defmodule SecretSanta.Users do
  alias SecretSanta.User
  alias SecretSanta.Repo

  def get_users_count() do
    Repo.aggregate(User, :count, :id)
  end

  def get_user!(id), do: Repo.get!(User, id)
  def get_by_username(username), do: Repo.get_by(User, username: username)

  def update_user(%User{} = user, attrs) do
    user
      |> User.changeset(attrs)
      |> Repo.update()
  end
end
